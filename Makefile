.PHONY: all
all: dist/ma_house.geojson dist/ma_senate.geojson

# Attempting to balance file size with accuracy, mostly emperically
# 50m ~= 1/2 a city block, and 4 decimals of precision == 11.1m
# https://www.google.com/search?q=average+city+block+length
# https://en.wikipedia.org/wiki/Decimal_degrees#Precision
simplify := interval=50m
output := precision=0.0001

dist/ma_%.geojson: cache/gis/%2012_poly.shp dist/ma_legislators.json
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
		http://download.massgis.digital.mass.gov/cache/state/$(notdir $@)

# TODO: Generate CSV as a convenience
dist/ma_legislators.json:
	mkdir -p dist cache
	venv/bin/python scripts/scrape_ma_legislators.py > $@
	ls -lh $@
	head -c 1024 $@

# TODO: Add distinct clean-dist and clean-cache, via clean-%, but see:
# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: clean
clean:
	rm -rf dist cache
