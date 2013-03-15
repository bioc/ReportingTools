setMethod(   '[[<-', c(x="HTMLReportRef"),  function(x, i, ...,value)
    {
      x$addElement(name = i, value = value, ...)
      x
    })

setMethod("[[", c(x="HTMLReportRef"),  function(x, i, exact = TRUE) 
    x$.report[[i, exact = exact]])
 
setMethod("publish", 
    signature = signature(object = "ANY", publicationType = "HTMLReportRef"), 
    definition = function(object, publicationType, .addColumns = NULL, 
        .toDF = NULL, ...) 
        publicationType$addElement(value = object, ..., 
            .addColumns = .addColumns, .toDF = .toDF ))

setMethod("finish",
    signature = signature(publicationType = "HTMLReportRef"),
    definition = function(publicationType, ...){
        publicationType$finish(...)
    }
)

setMethod("path", "HTMLReportRef", function(obj)
          {
            sapply(obj$handlers, path)
          })