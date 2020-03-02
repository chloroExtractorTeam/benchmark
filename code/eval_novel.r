library(tidyverse)
library(UpSetR)
library(RColorBrewer)

my_col=brewer.pal(7,"Set2")

novel <- read_tsv("novel_novel.tsv", col_names=c("dataset","assembler","irlen","len","contigs"))
novel_success <- novel %>% filter(contigs==1,len>=130000,irlen>=17000) 
novel_success %>% count(assembler)
novel_success %>% select(dataset) %>% unique %>% dim
novel_success %>% write_tsv("novel_success.tsv")

## create upsetplot 
pdf("plots/upset_novel.pdf", onefile=FALSE)
UL  = novel_success %>% select(dataset,assembler) %>% split(.$assembler) %>% lapply("[[",1)
upset(fromList(UL), order.by = "freq",sets.bar.color=my_col[c(4,3,6,7,2)],
      point.size=5,matrix.color = my_col[3],
      shade.alpha = 0.5, text.scale = 1.5)
dev.off()

