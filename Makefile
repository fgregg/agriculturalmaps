include crop_variables.mk

crops.tif : crops.vrt
	gdal_translate -co COMPRESS=DEFLATE $< $@

crops.vrt : sugarbeets.tif dry_beans.tif corn.tif oats.tif	\
            winter_wheat.tif potatoes.tif
	gdalbuildvrt -separate $@ $^

# would be good to improve with something that calculated the
# density of farms per cell grid. could probably do that with
# spatialite
%.tif : crops.geojson
	gdal_rasterize \
           -burn 1 \
           -ts 1000 1000 \
           -where "CDL2023 = '$($*)'" \
           -of GTiff $< $@

crops.geojson : NationalCSB_2016-2023_rev23/CSB1623.gdb
	ogr2ogr -f "GeoJSON" $@ $< -sql "SELECT * FROM national1623 WHERE STATEFIPS='26'" -t_srs EPSG:4326

NationalCSB_2016-2023_rev23/CSB1623.gdb : NationalCSB_2016-2023_rev23.zip
	unzip $<

NationalCSB_2016-2023_rev23.zip : 
	curl -o $@ "https://www.nass.usda.gov/Research_and_Science/Crop-Sequence-Boundaries/datasets/NationalCSB_2016-2023_rev23.zip"
