# Massachusetts Legislature Data

Geographic data for the Massachusetts legislature.

Open any `.geojson` file on GitHub to view the data on a map. See [Mapping geoJSON files on GitHub](https://docs.github.com/en/github/managing-files-in-a-repository/mapping-geojson-files-on-github) for details.

Feedback welcome on the [issue tracker](https://github.com/bhrutledge/ma-legislature/issues).

## Build instructions

Install the NPM dependencies:

```
npm install
```

Then, to re-download the data and rebuild the output, run:

```
make -B
```

## Data sources

- <https://docs.digital.mass.gov/dataset/massgis-data-massachusetts-house-legislative-districts>
- <https://docs.digital.mass.gov/dataset/massgis-data-massachusetts-senate-legislative-districts>
