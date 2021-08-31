library(sf)
library(stringi)
library(tidyverse)
set.seed(123)
# Load Shape Files
load("../../SALURBAL COVID-19 Dashboard/Data/salurbal_l1_sf_simp.rdata")
load("../../SALURBAL COVID-19 Dashboard/Data/sf_salurbal_0.8.rdata")
sf_l1_simp = salurbal_l1_sf_simp %>% 
  select(salid1, country, name)
sf_l1_hex = sf_salurbal_0.8%>% 
  select(salid1, country, name)
save(sf_l1_simp,sf_l1_hex,
     file = "../App/sf_files.rdata")

bogus_l1_data = sf_l1_simp %>% 
  as_data_frame() %>% 
  select(-geometry)  %>% 
  group_by(country) %>% 
  group_modify(~{
    L1_count = .x %>% nrow()
    .x %>% 
      mutate(var_burgerKingPer100k = rnorm(L1_count,rnorm(1, 1000,150), rnorm(1,150,25)),
             var_catsPer100k =  rnorm(L1_count,rnorm(1, 400,25), rnorm(1,20,2)))
  }) %>% 
  ungroup() %>% 
  select(-country, -name)
write.csv(bogus_l1_data,file = "bogus_l1_data_v2.csv")

