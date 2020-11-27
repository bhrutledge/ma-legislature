# Massachusetts Legislature Data

Open any `.geojson` file on GitHub to view the data on a map. See [Mapping geoJSON files on GitHub](https://docs.github.com/en/github/managing-files-in-a-repository/mapping-geojson-files-on-github) for details.

**CAVEAT**: I have no GIS training; I'm just a software engineer who likes maps. So, it's very likely that there are some best practices I have not, well, practiced. For example, to reduce the file size, I made some judgment calls to simplify the district borders. See the [Makefile](./Makefile) for details.

Feedback welcome on the [issue tracker](https://github.com/bhrutledge/ma-legislature/issues).

## Build instructions

Install the NPM dependencies (i.e. [mapshaper](https://github.com/mbloch/mapshaper)):

```
npm install
```

Then, to re-download the data and rebuild the output, run:

```
make -B
```

## Data sources

- [MassGIS Data: Massachusetts House Legislative Districts](https://docs.digital.mass.gov/dataset/massgis-data-massachusetts-house-legislative-districts)
- [MassGIS Data: Massachusetts Senate Legislative Districts](https://docs.digital.mass.gov/dataset/massgis-data-massachusetts-senate-legislative-districts)
