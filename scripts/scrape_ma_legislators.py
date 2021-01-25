"""
Scrape legislator names and contact info from https://malegislature.gov/Legislators.

TODO: Replace this with a Scrapy project.
"""
import functools
import json
import pathlib
import sys
import warnings
from collections import OrderedDict

import requests
import requests_cache
import urllib3
from bs4 import BeautifulSoup
from tqdm import tqdm

BASE_URL = "https://malegislature.gov"
FILE_DIR = pathlib.Path(__file__).parent.resolve()
CACHE_DIR = FILE_DIR.parent / "cache"

requests_cache.install_cache(str(CACHE_DIR / "ma_legislators_requests"))

debug = functools.partial(print, file=sys.stderr)


def select_string(soup, selector):
    try:
        return (soup.select_one(selector).string or "").strip()
    except AttributeError:
        return ""


def get_soup(url):
    # debug(url)
    # HACK: Work around SSLError "unable to get local issuer certificate"
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", urllib3.exceptions.InsecureRequestWarning)
        response = requests.get(url, verify=False)

    response.raise_for_status()
    # debug(f"Status: {response.status_code}, Cached: {response.from_cache}")

    return BeautifulSoup(response.text, "lxml")


def parse_chamber(soup):
    for row_soup in tqdm(soup.select("#legislatorTable tbody tr")):
        profile = OrderedDict()

        first_name = select_string(row_soup, "td:nth-of-type(3)")
        last_name = select_string(row_soup, "td:nth-of-type(4)")
        profile_url = BASE_URL + row_soup.select_one("td:nth-of-type(3) a")["href"]

        if first_name == "Vacant":
            district = last_name
            title = full_name = last_name = ""
        else:
            district = select_string(row_soup, "td:nth-of-type(5)")
            profile_soup = get_soup(profile_url)
            title_tag = profile_soup.select_one("h1 span")
            title = title_tag.string.strip()
            full_name = title_tag.next_sibling.string.strip()

        profile["chamber"] = select_string(soup, "h1").split()[0]
        profile["district"] = district
        profile["title"] = title
        profile["full_name"] = full_name
        profile["first_name"] = first_name
        profile["last_name"] = last_name
        profile["party"] = select_string(row_soup, "td:nth-of-type(6)")
        profile["url"] = profile_url
        profile["email"] = select_string(row_soup, "td:nth-of-type(9) a")
        profile["phone"] = select_string(row_soup, "td:nth-of-type(8)")
        profile["room"] = select_string(row_soup, "td:nth-of-type(7)")
        profile["photo"] = BASE_URL + row_soup.select_one(".thumb img")["src"]

        yield profile


def get_chamber(chamber_name):
    chamber_url = f"{BASE_URL}/Legislators/Members/{chamber_name.title()}"
    debug(chamber_url)
    chamber_soup = get_soup(chamber_url)
    chamber = list(parse_chamber(chamber_soup))

    debug(json.dumps([chamber[0], "...", chamber[-1]], indent=2))

    return chamber


def main():
    representatives = get_chamber("house")
    senators = get_chamber("senate")
    json.dump(representatives + senators, sys.stdout)


if __name__ == "__main__":
    main()
