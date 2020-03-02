library(tidyverse)

data <- read_tsv("features.tsv", col_names=c("genome","feature","gene"))

data %>% group_by(genome) %>% count(feature) %>% ggplot(aes(x=n,fill=feature)) + geom_density()
ggsave("feature_counts.svg")
ggsave("feature_counts.png")
data %>% unique %>% group_by(genome) %>% count(feature) %>% ggplot(aes(x=n,fill=feature)) + geom_density()
ggsave("feature_counts_distinct.svg")
ggsave("feature_counts_distinct.png")

data %>%
	group_by(genome) %>%
	count(feature) %>%
	group_by(feature) %>%
	summarize(mean=mean(n), sd=sd(n), median=median(n), iqr=IQR(n))
data %>%
	unique %>%
	group_by(genome) %>%
	count(feature) %>%
	group_by(feature) %>%
	summarize(mean=mean(n), sd=sd(n), median=median(n), iqr=IQR(n))

# outlier (low uniq counts):
data %>% unique %>% group_by(genome) %>% count(feature) %>% filter(genome=="ERR1917165_fast")
