setMethod("addReportColumns",
          signature = signature(
            object = "ANY"),
          definition=function(df, htmlRep, ...) df
          )
setMethod("addReportColumns",
          signature = signature(
            object = "GOHyperGResult"),
          definition = function(df, htmlRep, object, annotation.db, selectedIDs, pvalueCutoff = 0.01, categorySize = 10,...)
          {
	tryCatch(getAnnMap("SYMBOL", annotation.db), error=function(e)
		{stop(paste0("Unable to find your annotation.db: ",annotation.db))})
	check.eg.ids(selectedIDs,annotation.db)


  	if(dim(df)[1]<1) {stop("No categories match your criteria.")}
  	df$GOID<-df[,1]
   	df$GOLink<-paste('<a href="http://amigo.geneontology.org/cgi-bin/amigo/term_details?term=', df$GOID, '">', df$GOID, '</a>', sep="")
   	df$goName<-unlist(lapply(df$GOID, function(x) {strsplit(x, ":")[[1]][2]}))
   	
   	#pages.dirname <- paste0('GOPages', name(htmlRep))
        pages.dirname <- paste0('GOPages', htmlRep$shortName)  
   # page.directory <- file.path(basePath(htmlRep), 
    #    reportDirectory(htmlRep), pages.dirname)
        page.directory <- file.path(htmlRep$basePath,
                                    htmlRep$reportDirectory, pages.dirname)
    .safe.dir.create(page.directory)
    go.reportDirectory <- paste(htmlRep$reportDirectory, 
        pages.dirname, sep="/")
   	makeGeneListPages(object,reportDir=go.reportDirectory,  pvalueCutoff=pvalueCutoff,categorySize,selectedIDs, annotation.db, GO=TRUE, baseUrl=htmlRep$baseUrl, basePath=htmlRep$basePath)  
   	
   	df$CountLink<-paste('<a href="',pages.dirname, "/" ,df$goName, ".html",'">', df$Count, '</a>', sep="")
   	df$SizeLink<-paste('<a href="',pages.dirname, "/",df$goName, "All.html",'">', df$Size, '</a>', sep="")
 	ret<-data.frame(df$GOLink,df$Term,df$SizeLink,Image = rep("", nrow(df)), df$CountLink,signif(df$OddsRatio, 3), signif(df$Pvalue, 3),stringsAsFactors = FALSE)
 	colnames(ret)<-c("Accession", "GO Term","Category Size" ,"Image","Overlap", "Odds Ratio", "P-value" )
 
 	figure.dirname <- paste0('GOFigures', htmlRep$shortName)
    figure.directory <- file.path(htmlRep$basePath, htmlRep$reportDirectory, figure.dirname)
    .safe.dir.create(figure.directory)
     #   if (makePlot==TRUE){
#		plotGOResults(object,pvalueCutoff, categorySize, reportDir=figure.directory)
#		plotret = hwrite(hwriteImage(paste(figure.dirname,"GOPlot.svg", sep="/"), link=paste(figure.dirname,"GOPlot.svg", sep="/"),width=400, height=400), br = TRUE)
#	}
    numSelectedIDs<-length(selectedIDs)    
	largestTerm<-max(df$Size)
	for (i in 1:dim(df)[1]){
  		GONum<-as.character(strsplit(df$GOID[i], ":")[[1]][2])
  		png.filename <- paste(GONum ,"png", sep='.')
 	 	png.file <- file.path(figure.directory, png.filename)
  		png(png.file)
  		hyperGPlot(df$Size[i]-df$Count[i],numSelectedIDs-df$Count[i], df$Count[i], df$GOID[i], df$Term[i])
  		dev.off()
  		
  		pdf.filename <- paste(GONum, "pdf", sep=".")
        pdf.file <- file.path(figure.directory, pdf.filename)
        pdf(pdf.file)
  		hyperGPlot(df$Size[i]-df$Count[i],numSelectedIDs-df$Count[i], df$Count[i], df$GOID[i], df$Term[i])
        dev.off()
        
        ret$Image[i] <- hwriteImage(paste(figure.dirname,png.filename, sep="/"), link=paste(figure.dirname,pdf.filename, sep="/"), table=FALSE,width=100, height=100)
	}
#XXX We need to figure out another way to do this This logic doesn't belong in addReportColumns
        
 #       if(makePlot)
          #If we have the plot we need to mash it all together into HTML here because of how the dispatch is currently set up. We may want to change this in the future...
  #        paste("<div>",retplot, objectToHTML(ret), "</div>", sep="\n") 
   #     else
          ret


          })