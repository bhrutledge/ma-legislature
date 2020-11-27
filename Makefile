.PHONY: all
all: ma_house.geojson

ma_house.geojson: shapefiles/HOUSE2012_POLY.shp
	npx mapshaper $< \
		-filter-fields DIST_CODE,REP_DIST,URL \
		-rename-fields district=REP_DIST,code=DIST_CODE,legislator=URL \
		-proj wgs84 \
		-simplify 5% \
		-info \
		-o $@
	@ls -lh $@

shapefiles/HOUSE2012_POLY.shp: shapefiles/house2012.zip
	unzip -d shapefiles -o -DD $<

shapefiles/house2012.zip:
	curl --create-dirs --output $@ \
		http://download.massgis.digital.mass.gov/shapefiles/state/$(notdir $@)

.PHONY: clean
clean:
	rm -rf *.geojson shapefiles
