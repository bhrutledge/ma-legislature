# Massachusetts Legislature Data

The [`dist/`](/dist) directory contains GeoJSON files of the House and Senate districts with legislator information, and a JSON file of just the legislator information.

See <https://bhrutledge.com/ma-legislature> for a map built with [Leaflet](https://leafletjs.com/), hosted on GitHub Pages. Hopefully this can serve as an example for similar maps.

**CAVEAT**: I have no GIS training; I'm just a software engineer who likes maps. So, it's very likely there are some best practices that I have not, well, practiced. For example, to reduce the file size, I made some judgment calls to simplify the district borders. See the [Makefile](./Makefile) for details.

Feedback welcome on the [issue tracker](https://github.com/bhrutledge/ma-legislature/issues).

## Generating the data

Install the project's dependencies:

```
npm install
python3 -m venv venv
venv/bin/pip install -r requirements.txt
```

Then, to re-download the data and rebuild the output, run:

```
make -B
```

This will:

- Download the [House](https://docs.digital.mass.gov/dataset/massgis-data-massachusetts-house-legislative-districts) and [Senate](https://docs.digital.mass.gov/dataset/massgis-data-massachusetts-senate-legislative-districts) legislative district shapefiles from [MassGIS](https://docs.digital.mass.gov/dataset/massgis-data-layers)
- Scrape legislator information from [malegislature.gov/Legislators](https://malegislature.gov/Legislators) and save it as [JSON](dist/ma_legislators.json)
- Generate GeoJSON for the [House](dist/ma_house.geojson) and [Senate](dist/ma_senate.geojson) districts with legislator information (using [mapshaper](https://github.com/mbloch/mapshaper))

**NOTE**: When scraping, the HTTP requests are cached to facilitate development and avoid excessive traffic. To re-scrape the data, delete `cache/ma_legislators_requests.sqlite`.

## Building the map

Install the dependencies:

```sh
npm install
```

Run the development server:

```sh
npm start
```

View the map at <http://localhost:3000>.

Publish changes by pushing them to the `main` branch.
