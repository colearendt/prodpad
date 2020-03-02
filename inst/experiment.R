pcl <- prodpad()


hm <- pcl$GET("/feedbacks?size=1000")
fdbk <- tibble::tibble(dat = hm)

fdbk_prep <- fdbk %>% unnest_wider(dat) %>% unnest_wider(added_by, names_sep = "_")


tags <- pcl$GET("/tags?size=1000")
tag_dat <- tibble::tibble(dat = tags) %>% unnest_wider(dat)

cmp1 <- pcl$GET("/companies?page=1")
cmp2 <- pcl$GET("/companies?page=2")

company_dat <- tibble::tibble(dat = c(cmp1$companies, cmp2$companies)) %>% unnest_wider(dat)

contacts <- pcl$GET("/contacts?size=10000")
contact_dat <- tibble::tibble(dat = contacts$contacts) %>% unnest_wider(dat)

ideas <- pcl$GET("/ideas?size=1000")
ideas_dat <- tibble::tibble(dat = ideas$ideas) %>% unnest_wider(dat) %>% unnest_wider(creator, names_sep = "_")
