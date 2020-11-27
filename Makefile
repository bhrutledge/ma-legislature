.PHONY: all
all: ma_house.geojson ma_senate.geojson

ma_%.geojson: shapefiles/%2012_poly.shp
	npx mapshaper $< \
		-each "district = this.properties.REP_DIST || this.properties.SEN_DIST" \
		-each "legislator=URL" \
		-filter-fields district,legislator \
		-proj wgs84 \
		-simplify 5% \
		-info \
		-o $@
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
