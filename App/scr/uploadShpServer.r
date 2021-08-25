sf <- reactive({
  req(input$selectFilemap)
  selectFilemapTmp <- input$selectFilemap
  
  # Name of the temporary directory where files are uploaded
  tempdirname <- dirname(selectFilemapTmp$datapath[1])
  # Rename files
  for (i in 1:nrow(selectFilemapTmp)) {
    file.rename(
      selectFilemapTmp$datapath[i],
      paste0(tempdirname, "/", selectFilemapTmp$name[i])
    )
  }
  save(shpdf,file = "shpdf_renaemd.rdata")
  # Now we read the shapefile with readOGR() of rgdal package
  # passing the name of the file with .shp extension.
  
  # We use the function grep() to search the pattern "*.shp$"
  # within each element of the character vector shpdf$name.
  # grep(pattern="*.shp$", shpdf$name)
  # ($ at the end denote files that finish with .shp,
  # not only that contain .shp)
  sf <- readOGR(paste(tempdirname,
                      shpdf$name[grep(pattern = "*.shp$", shpdf$name)],
                      sep = "/"
  )) %>% st_as_sf()
  sf
})
