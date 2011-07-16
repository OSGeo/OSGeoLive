core <- c("classInt", "DCluster", "deldir", "geoR", "gstat", "maptools",
"RandomFields", "raster", "RColorBrewer", "rgdal", "sp", "spatstat",
"spdep", "splancs" )

#optional <- c("ade4", "adehabitat", "adehabitatHR", "adehabitatHS", "adehabitatLT", "adehabitatMA", "ads", "akima", "ash", "aspace", "automap", "CircSpatial", "clustTool", "CompRandFld", "constrainedKriging", "cshapes", "diseasemapping", "DSpat", "ecespa", "fields", "FieldSim", "gdistance", "Geneland", "GEOmap", "geomapdata", "geonames", "geoRglm", "geosphere", "GeoXp", "glmmBUGS", "gmaps", "gmt", "Guerry", "hdeco", "intamap", "mapdata", "mapproj", "maps", "MarkedPointProcess", "MBA", "ModelMap", "ncdf", "ncf", "nlme", "pastecs", "PBSmapping", "PBSmodelling", "psgp", "ramps", "RArcInfo", "regress", "rgeos", "RgoogleMaps", "RPyGeo", "RSAGA", "RSurvey", "rworldmap", "sgeostat", "shapefiles", "sparr", "spatcounts", "spatgraphs", "spatial", "spatialCovariance", "SpatialExtremes", "spatialkernel", "spatialsegregation", "spBayes", "spcosa", "spgrass6", "spgwr", "sphet", "spsurvey", "SQLiteMap", "Stem", "tgp", "trip", "tripack", "tripEstimation", "UScensus2000", "vardiag", "vegan") 

#non-spatial <- c("RPostgresql","RSQLite","RODBC")

packagelist <- core

for (i in packagelist) {
	#Generic Version followed by Australian Repos
	#install.packages(i, repos= "http://cran.r-project.org", lib = "/usr/local/lib/R/site-library/" , dependencies = TRUE)
	#For AU builds	
	#install.packages(i, repos= "http://cran.ms.unimelb.edu.au/", lib = "/usr/local/lib/R/site-library/")
	#For EU builds
	#install.packages(i, repos= "http://stat.ethz.ch/CRAN/", lib = "/usr/local/lib/R/site-library/") 
	#For US builds
	install.packages(i, repos= "http://cran.cnr.Berkeley.edu/", lib = "/usr/local/lib/R/site-library/") 
	output <- paste("Finished installing",i,sep=" ")
	print(output)
}

q()
