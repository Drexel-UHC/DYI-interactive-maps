library(sf)
library(stringi)
library(tidyverse)
set.seed(123)
# Load Shape Files
load("../../SALURBAL COVID-19 Dashboard/Data/salurbal_l1_sf_simp.rdata")
load("../../SALURBAL COVID-19 Dashboard/Data/sf_salurbal_0.8.rdata")
l1_keys = salurbal_l1_sf_simp %>% 
  mutate(key = stri_rand_strings(nrow(salurbal_l1_sf_simp), 10, pattern = "[A-Za-z0-9]")) %>% 
  as_data_frame() %>% 
  select(salid1,key)

shp_bogus_l1 = salurbal_l1_sf_simp %>% 
  left_join(l1_keys) %>% 
  select(key,country, name)
st_write(shp_bogus_l1, "l1.shp",  delete_layer  = T)

# Load Hex
hex_bogus_l1 = sf_salurbal_0.8 %>% 
  left_join(l1_keys %>% select(key, salid1)) %>% 
  select(key, country, name)
st_write(hex_bogus_l1, "hex_l1.shp",  delete_layer  = T)

## Save as rdta
fileSfL1 = shp_bogus_l1
fileSfL1Hex = hex_bogus_l1
save(fileSfL1,fileSfL1Hex, file = "../App/default_shp.rdata")

## Simulate burger data
bogus_l1_data = shp_bogus_l1 %>% as_data_frame() %>% 
  select(-geometry)  %>% 
  left_join(bogus_l1_means) %>% 
  group_by(country) %>% 
  group_modify(~{
    L1_count = .x %>% nrow()
    .x %>% 
      mutate(var_burgerKingPer100k = rnorm(L1_count,rnorm(1, 1000,150), rnorm(1,150,25)),
             var_catsPer100k =  rnorm(L1_count,rnorm(1, 400,25), rnorm(1,20,2)))
  }) %>% 
  ungroup() %>% 
  select(-mean)
write.csv(bogus_l1_data,file = "bogus_l1_data.csv")

