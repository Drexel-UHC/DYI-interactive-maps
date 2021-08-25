data = read.csv("bogus_l1_data.csv")
sf_raw = readOGR("l1.shp") %>% st_as_sf()
palleteTmp = "YlOrRd"
palleteTmp = "Blues"
varsTmp = "var_burgerKingPer100k"
