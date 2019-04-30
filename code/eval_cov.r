require(tidyverse)

res <- read_tsv("res.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))

out_tibble <- res %>% mutate(rep_res =  qry_cov/ref_cov ) %>% mutate(score =  1 - (abs(1-ref_cov_frac) + abs(1-qry_cov_frac) + abs(1-rep_res) + abs(1-(1/contig_num))))

out_tibble %>% ggplot(aes(x=assembler,y=dataset,fill=score)) + geom_tile() ;  ggsave("Plot.pdf")
