dps = c("tidyverse","dabestr","UpSetR")                   
sapply(dps,function(x){if(!require(x,character.only = T)){install.packages(x);library(x,character.only = T)}else{library(x,character.only = T)}})




res <- read_tsv("res.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))

out_tibble <- res %>% mutate(rep_res =  qry_cov/ref_cov ) %>% mutate(score =  1 - (abs(1-ref_cov_frac) + abs(1-qry_cov_frac) + abs(1-rep_res) + abs(1-(1/contig_num))))

out_tibble %>% ggplot(aes(x=assembler,y=dataset,fill=score)) + geom_tile() ;  ggsave("Plot.pdf")

out_tibble %>% ggplot(aes(y=score,x=assembler)) + geom_violin(adjuts=1000) + coord_cartesian(ylim = c(-2.5, 1.25)) + geom_boxplot(alpha=0.25,width=0.25) + geom_jitter() ; ggsave("Violin.pdf")


upssetlist  = out_tibble %>% filter(score>0.99)  %>% select(dataset,assembler) %>% split(.$assembler) %>% lapply("[[",1)


pdf("UpSet.pdf")
upset(fromList(upssetlist), order.by = "freq")
dev.off()



unpaired_mean_diff <- dabest(out_tibble %>% drop_na, y= score ,x= assembler,
                             idx = unique(out_tibble$assembler),
                             paired = F)

plot("Swarm.pdf")
plot(unpaired_mean_diff)
dev.off()
