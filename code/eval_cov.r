dps = c("tidyverse","dabestr","UpSetR","RColorBrewer","ggbeeswarm")                   
sapply(dps,function(x){if(!require(x,character.only = T)){install.packages(x);library(x,character.only = T)}else{library(x,character.only = T)}})




## load output file from alignment analyis

res <- read_tsv("res2.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))

res_sim  <- read_tsv("res.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))

out_tibble <- res %>% mutate(rep_res = exp(-abs(log(qry_cov/ref_cov)))) %>%
    mutate(score =  1 - (abs(1-ref_cov_frac) + abs(1-qry_cov_frac) + abs(1-rep_res) + abs(1-(1/contig_num))))

head(out_tibble)

## tile plot for simulated data 
out_tibble_sim %>% ggplot(aes(x=assembler,y=dataset,fill=score)) + geom_tile() 


## swarm plot for 

out_tibble %>% ggplot(aes(y=score,x=assembler,col=assembler)) + geom_boxplot(notch=F,alpha=0.3,width=0.2,color="black",fill="#c0c0c0")+ geom_quasirandom() + theme_bw()


n_obs = paste0("n=", out_tibble %>% drop_na %>% group_by(assembler) %>%  tally() %>% select(n) %>% unlist)



upssetlist  = out_tibble %>% filter(score>0.9)  %>% select(dataset,assembler) %>% split(.$assembler) %>% lapply("[[",1)




png("UpSet.png")
upset(fromList(upssetlist), order.by = "freq")
dev.off()



## Plot computation time etc

run_log <- read_tsv("log.tsv")
png("runtime.png")
run_log %>% filter(exit_code==0) %>% ggplot(aes(y=run_time_sec,x=as.factor(threads), fill=program)) + geom_boxplot()  + coord_cartesian (ylim=c(0,3500)) +theme_bw()
dev.off()
