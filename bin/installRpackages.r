packagelist <- c("ade4","adehabitat","ads","akima","ash","aspace","automap","clustTool","diseasemapping","ecespa","fields","GEOmap","geomapdata","geonames","geoR","geoRglm","GeoXp","glmmBUGS","gmaps","gmt","grasp","hdeco","mapdata","mapproj","MBA","ModelMap","ncdf","ncf","pastecs","PBSmapping","PBSmodelling","ramps","RArcInfo","regress","RgoogleMaps","RPyGeo","RSAGA","RSurvey","sgeostat","shapefiles","spatclus","spatgraphs","spatialCovariance","SpatialExtremes","spatialkernel","spBayes","spsurvey","SQLiteMap","tgp","tossm","trip","tripEstimation","vegan","VR","adapt","boot","class","classInt","coda","DCluster","digest","e1071","epitools","foreign","gpclib","graph","gstat","lattice","lmtest","maps","maptools","Matrix","mgcv","nlme","pgirmess","pkgDepTools","R2WinBUGS","RandomFields","RBGL","RColorBrewer","rgdal","Rgraphviz","sandwich","sp","spam","spatialkernel","spatstat","spdep","spgrass6","spgwr","splancs","tripack","xtable","zoo")

for (i in packagelist) {
	#Generic Version followed by Australian Repos
	#install.packages(i, repos= "http://cran.r-project.org", lib = "/usr/local/lib/R/site-library/" , dependencies = TRUE)
	install.packages(i, repos= "http://cran.ms.unimelb.edu.au/", lib = "/usr/local/lib/R/site-library/" , dependencies = TRUE)
	output <- paste("Finished installing",i,sep=" ")
	print(output)
}

q()
