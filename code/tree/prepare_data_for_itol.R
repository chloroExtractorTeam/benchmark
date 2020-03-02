library(tidyverse)
res <- read_tsv("res2.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))
out_tibble <- res %>% mutate(rep_res = exp(-abs(log(qry_cov/ref_cov)))) %>% mutate(score =  1 - (abs(1-ref_cov_frac) + abs(1-qry_cov_frac) + abs(1-rep_res) + abs(1-(1/contig_num))))

real_datasets <- read_tsv("../../data/real/real_datasets.tsv", col_names=c("sra","sciname","readlen","reference"))

left_join(select(real_datasets, dataset=sra, sciname), out_tibble) %>% mutate(success=if_else(is.na(score), -1, if_else(score>.95, 1, 0))) %>% select(sciname, assembler, success) %>% spread(assembler, success, fill=-1) %>% select(-`<NA>`) %>% write_csv("data_for_itol.csv")
