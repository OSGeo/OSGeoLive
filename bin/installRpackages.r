packagelist <- c("boot","class","classInt","DCluster","digest","epitools","gpclib","graph","gstat","maptools","Matrix","pgirmess","pkgDepTools","R2WinBUGS","RandomFields","RBGL","RColorBrewer","rgdal","Rgraphviz","sp","spam","spatialkernel","spatstat","spdep","spgrass6","spgwr","splancs","tripack","xtable")

for (i in packagelist) {
	#Generic Version followed by Australian Repos
	#install.packages(i, repos= "http://cran.r-project.org", lib = "/usr/local/lib/R/site-library/" , dependencies = TRUE)
	install.packages(i, repos= "http://cran.ms.unimelb.edu.au/", lib = "/usr/local/lib/R/site-library/" , dependencies = TRUE)
	output <- paste("Finished installing",i,sep=" ")
	print(output)
}

q()
