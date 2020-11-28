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

requests_cache.install_cache(str(FILE_DIR / "ma_legislators_cache"))

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


CLEAN_URLS = {
    f"{BASE_URL}/Legislators/District/4thHampden": {
        "chamber": "House",
        "district": "4th Hampden",
    }
}


def parse_chamber(soup):
    for row_soup in tqdm(soup.select("#legislatorTable tbody tr")):
        # TODO: Rework this to be more flexible/informative about missing data
        # e.g., "Vacant"
        row = parse_leg_row(row_soup)

        profile_soup = get_soup(row["url"])

        try:
            profile = parse_leg_profile(profile_soup)
        except AttributeError as exc:
            debug(f"Error parsing {row['url']}: {exc}")
            profile = OrderedDict()

        profile.update(row)

        clean_data = CLEAN_URLS.get(profile["url"], {})
        profile.update(clean_data)

        yield profile


def parse_leg_row(soup):
    return OrderedDict(
        [
            ("first_name", select_string(soup, "td:nth-of-type(3)")),
            ("last_name", select_string(soup, "td:nth-of-type(4)")),
            ("party", select_string(soup, "td:nth-of-type(6)")),
            ("url", BASE_URL + soup.select_one("td:nth-of-type(3) a")["href"]),
            ("email", select_string(soup, "td:nth-of-type(9) a")),
            ("phone", select_string(soup, "td:nth-of-type(8)")),
            ("room", select_string(soup, "td:nth-of-type(7)")),
            ("photo", BASE_URL + soup.select_one(".thumb img")["src"]),
        ]
    )


def parse_leg_profile(soup):
    leg_type = soup.select_one("h1 span")
    return OrderedDict(
        [
            ("chamber", "Senate" if leg_type.string == "Senator" else "House"),
            ("district", soup.select_one(".subTitle").string.split("-")[1].strip()),
            ("full_name", leg_type.next_sibling.string.strip()),
        ]
    )


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
