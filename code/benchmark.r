require(tidyverse)
require(foreach)
require(data.table)

datasets = dir()[dir.exists(dir())]

tools = c("chloroextractor",
          "chloroplast_assembly_protocol",
          "org-asm",
          "novoplasty",
          "fastplast",
          "getorganelle",
          "ioga")
         


our_results = foreach(d  = 1:length(datasets)) %do% {
    dat = datasets[d]
    output = system(paste0("find ",dat," -name output.fa"), intern=T)
    fa = setNames(output,lapply(strsplit(output,"/"),"[[",2))
   
    foreach(i = tools) %do% {
        if(!(i %in% names(fa))){
            "NF"
        } else {
            tmp = scan(fa[[i]],what="character")
            if(length(tmp) == 0) {
            "EF"
            } else { 
                tmp2 = length(unname(unlist(lapply(sapply(tmp[seq(0,length(tmp),2)],function(x) { strsplit(x,"")}),length))))
            }
        }
    } %>% setNames(tools)
        
} %>% setNames(datasets)


our_tibble = rbindlist(our_results,idcol="SRA")  %>% as.tibble %>% gather("Assembler","Result",-1) %>% mutate(Result=if_else(Result %in% c("EF","NF"), 0, pmin(2, as.numeric(Result))))

our_tibble %>% ggplot(aes(y=SRA,x=Assembler,fill=as.factor(Result))) + geom_tile()  + scale_fill_brewer("Set2") ; ggsave("plot.pdf")

