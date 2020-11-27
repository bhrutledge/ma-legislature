.PHONY: all
all: ma_house.geojson ma_senate.geojson

# Attempting to balance file size with accuracy, mostly emperically
# 50m ~= 1/2 a city block, and 4 decimals of precision == 11.1m
# https://www.google.com/search?q=average+city+block+length
# https://en.wikipedia.org/wiki/Decimal_degrees#Precision
simplify := interval=50m
output := precision=0.0001

ma_%.geojson: shapefiles/%2012_poly.shp
	npx mapshaper -i $< \
		-each "district = this.properties.REP_DIST || this.properties.SEN_DIST" \
		-filter-fields district \
		-proj wgs84 \
		-simplify $(simplify) \
		-clean \
		-o $@ $(output)
	@ls -lh $@

.PRECIOUS: shapefiles/%_poly.shp
shapefiles/%_poly.shp: shapefiles/%.zip
	unzip -d shapefiles -o -DD -L $<

.PRECIOUS: shapefiles/%.zip
shapefiles/%.zip:
	curl --create-dirs --output $@ \
		http://download.massgis.digital.mass.gov/shapefiles/state/$(notdir $@)

.PHONY: clean
clean:
	rm -rf *.geojson shapefiles
