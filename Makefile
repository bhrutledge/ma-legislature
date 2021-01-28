house_geojson := dist/ma_house.geojson
senate_geojson := dist/ma_senate.geojson
legislators_json := dist/ma_legislators.json
legislators_csv := dist/ma_legislators.csv

.PHONY: all
all: $(house_geojson) $(senate_geojson) $(legislators_json) $(legislators_csv)

# Attempting to balance file size with accuracy, mostly emperically
# 50m ~= 1/2 a city block, and 4 decimals of precision == 11.1m
# https://www.google.com/search?q=average+city+block+length
# https://en.wikipedia.org/wiki/Decimal_degrees#Precision
simplify := interval=50m
output := precision=0.0001

dist/ma_%.geojson: cache/gis/%2012_poly.shp $(legislators_json)
	npx mapshaper -i $< \
		-each "district = this.properties.REP_DIST || this.properties.SEN_DIST" \
		-filter-fields district \
		-proj wgs84 \
		-simplify $(simplify) \
		-clean \
		-join $(word 2, $^) keys=district,district \
		-o $@ $(output)
	@ls -lh $@

.PRECIOUS: cache/gis/%_poly.shp
cache/gis/%_poly.shp: cache/gis/%.zip
	unzip -d $(dir $@) -o -DD -L $<

.PRECIOUS: cache/gis/%.zip
cache/gis/%.zip:
	curl --create-dirs --output $@ \
		http://download.massgis.digital.mass.gov/shapefiles/state/$(notdir $@)

$(legislators_csv): $(legislators_json)
	npx json2csv --input $< --output $@

$(legislators_json):
	mkdir -p dist cache
	venv/bin/python scripts/scrape_ma_legislators.py > $@
	ls -lh $@
	head -c 1024 $@
