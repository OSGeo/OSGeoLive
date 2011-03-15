packagelist <- c("boot","class","classInt","DCluster","digest","epitools","gpclib","graph","gstat","maptools","Matrix","pgirmess","pkgDepTools","R2WinBUGS","RandomFields","RBGL","RColorBrewer","rgdal","Rgraphviz","sp","spam","spatialkernel","spatstat","spdep","spgrass6","spgwr","splancs","tripack","xtable","rggobi","automaps","iplots")

#packagelist2 <- c("ade4","adehabitat","ads","akima","ash","aspace","automap","clustTool","diseasemapping","ecespa","fields","GEOmap","geomapdata","geonames","geoR","geoRglm","GeoXp","glmmBUGS","gmaps","gmt","grasp","hdeco","mapdata","mapproj","MBA","ModelMap","ncdf","ncf","pastecs","PBSmapping","PBSmodelling","ramps","RArcInfo","regress","RgoogleMaps","RPyGeo","RSAGA","RSurvey","sgeostat","shapefiles","spatclus","spatgraphs","spatialCovariance","SpatialExtremes","spatialkernel","spBayes","spsurvey","SQLiteMap","tgp","tossm","trip","tripEstimation","vegan","VR")

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
