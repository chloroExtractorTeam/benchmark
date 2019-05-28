dps = c("tidyverse","dabestr","UpSetR","RColorBrewer","ggbeeswarm","ggpmisc","xtable")                   
sapply(dps,function(x){if(!require(x,character.only = T)){install.packages(x);library(x,character.only = T)}else{library(x,character.only = T)}})


## load output file from alignment analyis
### order assemblers for ggplot
res <- read_tsv("results/res2_clean.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))

## simulated data 
res_sim  <- read_tsv("results/res_sim_clean.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))

## calculate the score for each assembly for real data
out_tibble <- res %>% mutate(rep_res = exp(-abs(log(qry_cov/ref_cov)))) %>%
    mutate(score =  (1 - ((abs(1-ref_cov_frac)/4) + (abs(1-qry_cov_frac)/4) + (abs(1-rep_res)/4) + (abs(1-(1/contig_num))/4)))*100)

## order the assemblers for ggplot
out_tibble$assembler_f <- factor(out_tibble$assembler, levels=c("CAP","CE","Fast-Plast","GetOrganelle","IOGA","NOVOPlasty","org.ASM"))


## calculate the score for each assembly for simulated  data 
out_tibble_sim <- res_sim %>% mutate(rep_res = exp(-abs(log(qry_cov/ref_cov)))) %>%
    mutate(score =  (1 - ((abs(1-ref_cov_frac)/4) + (abs(1-qry_cov_frac)/4) + (abs(1-rep_res)/4) + (abs(1-(1/contig_num))/4)))*100)

## order the assemblers for ggplot
out_tibble_sim$assembler_f <- factor(out_tibble_sim$assembler,
                                 levels=c("CAP","CE","Fast-Plast","GetOrganelle","IOGA","NOVOPlasty","org.ASM"))

## select colour pallette for plots 
my_col=brewer.pal(7,"Set2")

## create the tile plot for simulated data
out_tibble_sim %>% ggplot(aes(x=assembler,y=dataset,fill=score)) + geom_tile() + theme_bw()+
    scale_fill_continuous(low = my_col[2] ,high = my_col[1]) +
    theme(axis.title.y = element_blank(),axis.title.x=element_blank(),text = element_text(size=15))
ggsave("plots/sim_tiles.pdf")


## swarm plot for real datasets
out_tibble %>% drop_na %>%  ggplot(aes(y=score,x=assembler_f,color=assembler_f)) +
    geom_boxplot(notch=F,alpha=0.3,width=0.2,color="black",fill="#c0c0c0") +
    geom_quasirandom(size=1.9 ) + theme_bw()  + scale_color_manual(values=my_col) +
    theme(axis.title.x = element_blank(),text = element_text(size=15), legend.title=element_blank())
ggsave("plots/swarm.pdf")


### count the number of runs with output 
n_obs = paste0("n=", out_tibble %>% drop_na %>% group_by(assembler) %>%  tally() %>% select(n) %>% unlist)
n_obs

## create upsetplot 
pdf("plots/upset.pdf")
UL  = out_tibble %>% filter(score>99)  %>% select(dataset,assembler) %>% split(.$assembler) %>% lapply("[[",1)
upset(fromList(UL), order.by = "freq",sets.bar.color=my_col[c(4,3,6,7,2)],
      point.size=5,matrix.color = my_col[3],
      shade.alpha = 0.5, text.scale = 1.5)
dev.off()



## plot resources meassures
## load log file 
run_log <- read_tsv("results/log_clean.tsv")

## convert bytes to GB in log file 
run_log[,14:15] <- run_log[,14:15]  / 10^9

run_log_mem <- run_log %>%  filter(exit_code==0) %>%
    gather(key="usage",value="mag", cpu_usage_percent, peak_cpu_usage_percent, peak_memory_bytes,peak_disk_usage_bytes)
run_log_mem$amount_f <- factor(run_log_mem$amount, levels=c("25K","250K","2.5M"))


run_log_mem %>% group_by(program) %>% summarize(bla=mean(run_time_sec))

## plot boxplots for computataion times 
run_log_mem %>% filter(exit_code==0) %>%
    ggplot(aes(y=run_time_sec,x=as.factor(program), fill=as.factor(threads))) +
    geom_boxplot() + 
    theme_bw() + scale_fill_manual(values=my_col) +
    theme(text = element_text(size=15),legend.position = c(0.65,0.3)) +
    guides(fill=guide_legend(title="Number of threads")) +
    xlab("Assembler") + ylab("Run time (s)") + facet_wrap(amount_f~.,ncol=2) +
    scale_y_log10()

ggsave("plots/comp_time_log.pdf")


##plot memory and cpu usage
## convert tibble to long format for ggplot


##rename usage parameters in tibble for ggplot
new_usages = c("CPU usage (%)" , "Peak CPU usage (%)"," Peak memory (GB)", "Peak disk usage (GB)")
unique(run_log_mem$usage) 
for( i in 1:4){
    run_log_mem$usage[run_log_mem$usage == unique(run_log_mem$usage)[i]] <-  new_usages[i]
}

## adjust order of input data size 



## plot disk and memeory usage vs number of threads 
run_log_mem %>% ggplot(aes(y=mag,x=as.factor(threads), fill=program)) + geom_boxplot()  + theme_bw() +
    scale_fill_manual(values=my_col) + facet_grid(usage~. ,scales = "free_y")  + scale_color_manual(values=my_col) +
    theme(text = element_text(size=15), legend.title=element_blank(),axis.title.y=element_blank()) +
    xlab("Number of threads") + scale_y_log10()
ggsave("plots/cpu_mem_disk_usage.pdf")



## plot disk usage and memory vs input size and number of threads 
run_log_mem %>%   ggplot(aes(y=mag,x=as.factor(threads), fill=program)) + geom_boxplot()  +
    theme_bw() +scale_fill_manual(values=my_col) + facet_grid(usage~amount_f ,scales = "free_y")  +
    scale_color_manual(values=my_col) + 
    theme(text = element_text(size=15), legend.title=element_blank(),axis.title.y=element_blank()) +
    xlab("Number of threads") + scale_y_log10()
ggsave("plots/usage_amount_threads.pdf")



### Analyze re runs


res_re  <- read_tsv("results/res_re_clean.tsv",col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))


out_tibble_re <- res_re %>% mutate(rep_res = exp(-abs(log(qry_cov/ref_cov)))) %>%
    mutate(score =  (1 - ((abs(1-ref_cov_frac)/4) + (abs(1-qry_cov_frac)/4) + (abs(1-rep_res)/4) + (abs(1-(1/contig_num))/4)))*100)

## order the assemblers for ggplot
out_tibble_re$assembler_f <- factor(out_tibble_re$assembler, levels=c("CAP","CE","Fast-Plast","GetOrganelle","IOGA","NOVOPlasty","org.ASM"))


##filter out_tibble with re run datasets

out_re <- out_tibble[paste0(unlist(out_tibble[,1]),unlist(out_tibble[,2])) %in% paste0(unlist(out_tibble_re[,1]),unlist(out_tibble_re[,2])),]

out_re2 <- out_tibble_re[paste0(unlist(out_tibble_re[,1]),unlist(out_tibble_re[,2])) %in% paste0(unlist(out_re[,1]),unlist(out_re[,2])),]

out_j <- out_re %>% add_column(score_rerun=out_re2$score)


out_j %>% ggplot(aes(x=score,y=score_rerun,col=assembler)) + geom_point()  + theme_bw() +
    facet_wrap(~assembler,ncol=3) + 
    stat_poly_eq(formula = x ~ y,parse=T) +
    guides(col=guide_legend(ncol=2)) +
    theme(legend.title = element_blank(),legend.position = c(0.5,0.2), text=element_text(size=15)) +
    xlab("Score 1. run ") + ylab("Score 2. run")

ggsave("plots/repro.pdf")


out_tibble %>% drop_na %>% select(assembler, score) %>% group_by(assembler) %>%
    summarize(Mean=mean(score),
              Median=median(score),
              SD = sqrt(var(score)),
              N_perfect = length(which(score > 99)),
              N_tot = length(score)) %>%
    xtable
