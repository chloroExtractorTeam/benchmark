library(tidyverse)

res <- read_tsv("res_runs.tsv", col_names=c("dataset","assembler","ref_tot","ref_cov","ref_cov_frac","qry_tot","qry_cov","qry_cov_frac","contig_num"))
res %<>% mutate(rep_res = exp(-abs(log(qry_cov/ref_cov)))) %>% mutate(score = (1 - ((abs(1-ref_cov_frac)/4) + (abs(1-qry_cov_frac)/4) + (abs(1-rep_res)/4) + (abs(1-(1/contig_num))/4)))*100)
res <- mutate(res, true=(score>=99))
res <- res %>% replace_na(list(true=FALSE))

novel <- read_tsv("res_novel.tsv", col_names=c("dataset","assembler","ir_len","ctg_len","num_ctg"))

my_res <- left_join(select(res, dataset, assembler, score, true), novel)

eval_params <- function(ir, total, data=my_res){
	my_tab <- data %>% mutate(pred=(ir_len>=ir & ctg_len>=total)) %>% select(true,pred) %>% table
	sens <- my_tab["TRUE","TRUE"]/(my_tab["TRUE","TRUE"]+my_tab["TRUE","FALSE"])
	prec <- my_tab["TRUE","TRUE"]/(my_tab["TRUE","TRUE"]+my_tab["FALSE","TRUE"])
	f1 <- 2*(sens*prec)/(sens+prec)
	return(tibble(ir,total,prec,sens,f1))
}

crossing(ir=seq(0,25000,1000),total=seq(10000,150000,10000)) %>% rowwise %>% do(eval_params(.$ir,.$total)) %>% gather(measure,value,3:5) %>% filter(measure == "f1") %>% arrange(-value) %>% head(1) %>% print

pdf("novel_cutoffs.pdf")
crossing(ir=seq(0,25000,1000),total=seq(10000,150000,10000)) %>% rowwise %>% do(eval_params(.$ir,.$total)) %>% gather(measure,value,3:5) %>% ggplot(aes(total,ir,fill=value)) + geom_tile() + facet_grid(. ~ measure) + ggtitle("F1, sensitivity, and precision by total and ir length cutoffs")
crossing(ir=seq(0,25000,1000),total=seq(10000,150000,10000)) %>% rowwise %>% do(eval_params(.$ir,.$total)) %>% gather(measure,value,3:5) %>% ggplot(aes(total,color=as.factor(ir),y=value)) + geom_line() + facet_grid(. ~ measure) + ggtitle("F1, sensitivity, and precision by ir length cutoffs (and total)")
crossing(ir=seq(0,25000,1000),total=seq(10000,150000,10000)) %>% rowwise %>% do(eval_params(.$ir,.$total)) %>% gather(measure,value,3:5) %>% ggplot(aes(ir,color=as.factor(total),y=value)) + geom_line() + facet_grid(. ~ measure) + ggtitle("F1, sensitivity, and precision by total length cutoffs (and ir)")
dev.off()
