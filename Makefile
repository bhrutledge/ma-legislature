.PHONY: all
all: ma_house.geojson

ma_%.geojson: shapefiles/%2012_poly.shp
	npx mapshaper $< \
		-filter-fields DIST_CODE,REP_DIST,URL \
		-rename-fields district=REP_DIST,code=DIST_CODE,legislator=URL \
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
