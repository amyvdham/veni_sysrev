## ---- study2chunk ----
library(data.table)
library(stringr)
library(udpipe)
library(igraph)
library(wordcloud)
library(Matrix)
library(yaml)
library(Rmpfr)
library(topicmodels)
library(udpipe)
library(slam)
library(tidytext)
library(ggplot2)
library(textrank)
source("word_functions.R")
source("circle2.R")
#run_everything <- FALSE

## Look at POS tags?
browser()
if(isTRUE(tools::md5sum("study2_df.RData") == "21abb2622dfd94d8bd3473ed56697f9e")){
  df <- readRDS("study2_df.RData")
} else {
  stop("Note: Study 2 file is out of date. Please run this code manually.")
  recs <- data.table(read.csv("recs_final.csv"))
  if(!is.data.table(recs)){
    browser()
  }
  recs[, "doc" := 1:nrow(recs)]
  
  recs$AB <- tolower(recs$AB)
  if(!file.exists("english-ewt-ud-2.4-190531.udpipe")) {
    ud_model <- udpipe_download_model(language = "english")
  } else {
    ud_model <- udpipe_load_model("english-ewt-ud-2.4-190531.udpipe")
    ud_model <- udpipe_load_model(ud_model$file)
  }
  udp_res <- udpipe_annotate(ud_model, x = recs$AB, doc_id = recs$doc)
  df <- as.data.table(udp_res)
  saveRDS(df, "study2_df.RData")
}


# LDA analysis ------------------------------------------------------------

if(!isTRUE(tools::md5sum("Study2_lda_dims.txt") == "2d00a24d8b54ac898eec6cd104086a0f")){
  # Functions:
  harmonicMean <- function(logLikelihoods, precision = 2000L) {
    llMed <- median(logLikelihoods)
    as.double(llMed - log(mean(exp(-mpfr(logLikelihoods,
                                         prec = precision) + llMed))))
  }
  BIC <- function(ll, p, n){
    -2 * ll + p * log(n)
  }
  entropy <- function(post_prob){
    1 + (1/(nrow(post_prob) * 
              log(ncol(post_prob)))) * (sum(rowSums(post_prob * 
                                                      log(post_prob + 1e-12))))
  }
  
  # Preprocessing -----------------------------------------------------------
  
  # Frequency of word by doc
  nounbydoc <- df[df$upos %in% c("NOUN", "ADJ"), list(freq = .N), by = list(doc_id = doc_id, term = lemma)]
  df_lda <- nounbydoc #[nounbydoc$term %in% names(dict), ]
  df_lda <- df_lda %>%
    bind_tf_idf(term, doc_id, freq)
  summary(df_lda$tf_idf)
  
  select_words <- df_lda[!duplicated(df_lda$term), ]
  select_words <- select_words$term[select_words$tf_idf >= median(select_words$tf_idf)]
  df_lda <- df_lda[df_lda$term %in% select_words, ]
  
  dtm <- udpipe::document_term_matrix(document_term_frequencies(df_lda))
  yaml::write_yaml(dim(dtm), file = "Study2_lda_dims.txt")
  
  # Build topic models
  seqk <- seq(2, 20, 1)
  burnin <- 1000
  iter <- 1000
  keep <- 50
  set.seed(44773)
  res_lda <- lapply(seqk, function(k) {
    topicmodels::LDA(
      dtm,
      k = k,
      method = "Gibbs",
      control = list(
        burnin = burnin,
        iter = iter,
        keep = keep
      )
    )
  })
  
  ll <- sapply(res_lda, function(x){harmonicMean(x@logLiks[-c(1:(burnin/keep))])})
  
  K = seqk
  N = nrow(dtm)
  M = ncol(dtm)
  
  parameters <- K*(M-1)+N*(K-1)
  N <- nrow(dtm)
  bics <- BIC(ll, parameters, N)
  
  entropies <- sapply(res_lda, function(x){entropy(x@gamma)})
  
  p <- ggplot(data.frame(K = seqk, Entropy = entropies), aes(x = K, y = Entropy)) + geom_path() +
    xlab('Number of topics') +
    scale_y_continuous(limits = c(0,1)) +
    theme_bw()
  
  ggsave("study2_entropies.png", p, device = "png")
  ggsave("study2_entropies.svg", p, device = "svg")
  
  p <- ggplot(data.frame(K = seqk, ll = ll), aes(x = K, y = ll)) + geom_path() +
    geom_vline(xintercept = (which.max(ll)+1), linetype = 2) +
    xlab('Number of topics') +
    geom_smooth(method = "lm", formula = y~log(x), se = FALSE)+
    theme_bw()
  
  ggsave("study2_ll.png", p, device = "png")
  ggsave("study2_ll.svg", p, device = "svg")
  
  p <- ggplot(data.frame(K = seqk, BIC = bics), aes(x = K, y = BIC)) + geom_path() +
    geom_vline(xintercept = (which.min(bics)+1), linetype = 2) +
    xlab('Number of topics') +
    geom_smooth(method = "lm", formula = y~x, se = FALSE)+
    theme_bw()
  
  ggsave("study2_BIC.png", p, device = "png")
  ggsave("study2_BIC.svg", p, device = "svg")
}


# Keyword extraction ------------------------------------------------------

# Exclude words
if(isTRUE(tools::md5sum("study2_df_kw.RData") == "8c9b3d61fa7e9bb6a3b31962b11face1")){
  df_kw <- readRDS("study2_df_kw.RData")
} else {
  df_kw <- df[upos %in% c("NOUN", "ADJ"), ]
  df_kw <- df_kw[grepl("^[a-zA-Z].", df_kw$lemma), ]
  exclude_terms <- readLines("exclude_terms.txt")
  exclude_these <- unique(unlist(lapply(exclude_terms, grep, x = df_kw$lemma)))
  df_kw <- df_kw[-exclude_these, ]
  saveRDS(df_kw, "study2_df_kw.RData")
}

# No numeric values
# all(is.na(as.numeric(df_kw$lemma)))
#df_kw$lemma[nchar(df_kw$lemma) == 3]

if(isTRUE(tools::md5sum("study2_textrank.RData") == "dcaf7c9bab7a4abd86d19d4868fad780")){
  kw_tr <- readRDS("study2_textrank.RData")
} else {
  kw_tr <- textrank_keywords(x = df_kw$lemma[df_kw$upos %in% c("NOUN", "ADJ")], 
                             ngram_max = 3, sep = " ")
  saveRDS(kw_tr, "study2_textrank.RData")
}

if(isTRUE(tools::md5sum("study2_df_analyze.RData") == "e50ee4984e0872947342d868e3bc9144")){
  df_analyze <- readRDS("study2_df_analyze.RData")
} else {
  # Merge back with original data
  df_kw$keyword <- txt_recode_ngram(df_kw$lemma, compound = kw_tr$keywords$keyword, ngram = kw_tr$keywords$ngram, sep = " ")
  df_kw$keyword[!df_kw$keyword %in% kw_tr$keywords$keyword] <- NA
  
  df_analyze <- df_kw[!is.na(df_kw$keyword), ]
  dict <- read_yaml("yaml_dict.txt")
  res_cat <- cat_words(df_analyze$keyword, dict, handle_dups = "all")
  # Check coding issues
  #res_cat$dup
  #head(res_cat$unmatched)
  df_analyze <- merge_df(df_analyze, res_cat$words, "word_coded")
  saveRDS(df_analyze, "study2_df_analyze.RData")
}


# Wordcloud ---------------------------------------------------------------
# Frequency of word by doc
nounbydoc <- df_analyze[, list(freq = .N), by = list(doc_id = doc_id, term = word_coded)]
number_docs_words2 <- c(docs = length(unique(nounbydoc$doc_id)), words = length(unique(nounbydoc$term)))

nounbydoc$freq <- 1
dtm <- udpipe::document_term_matrix(document_term_frequencies(nounbydoc))
topterms <- colSums(dtm)
topterms <- sort(topterms, decreasing = TRUE)

# Select most common terms ------------------------------------------------
set.seed(720)
source("word_functions.R")
dtm_top <- dtm[, select_words(dtm, .975)]
dtm_top <- dtm_top[rowSums(dtm_top) > 0, ]

if(run_everything){

  # Wordcloud ---------------------------------------------------------------
  
  ## Word frequencies
  topterms <- colSums(dtm_top)
  topterms <- sort(topterms, decreasing = TRUE)
  word_freq <- data.frame(Word = names(topterms), Frequency = topterms, row.names = NULL)
  write.csv(word_freq, "study2_word_freq.csv", row.names = FALSE)
  df_plot <- word_freq
  df_plot$Word <- pretty_words(df_plot$Word)
  df_plot$Frequency <- sqrt(df_plot$Frequency)
  ## Visualise them with wordclouds
  p <- quote({
    set.seed(46)
    wordcloud(words = df_plot$Word, freq = df_plot$Frequency, scale = c(4,.4), max.words = 150, rot.per = 0,  random.order = FALSE, colors = brewer.pal(8, "Dark2"))
  })
  
  svg("study2_wordcloud.svg")
  eval(p)
  dev.off()
  
  png("study2_wordcloud.png")
  eval(p)
  dev.off()
}

# Feature importance ------------------------------------------------------
topterms <- colSums(dtm_top)
if(run_everything){
  baseline <- readRDS("baseline.RData")
  
  word_freq <- data.frame(Word = names(topterms), Frequency = topterms, row.names = NULL)
  df_plot <- word_freq
  categ <- read.csv("study1_categorization.csv", stringsAsFactors = FALSE)
  df_plot$cat <- categ$category[match(df_plot$Word, categ$name)]
  df_plot$faded <- df_plot$Word %in% baseline
  df_plot$Word <- pretty_words(df_plot$Word)
  
  df_plot <- df_plot[order(df_plot$Frequency, decreasing = TRUE), ]
  df_plot$Word <- ordered(df_plot$Word, levels = df_plot$Word[order(df_plot$Frequency)])
  
  cat_cols <- c(Outcome = "gray50", Indicator = "tomato", Cause = "gold", Protective = "forestgreen")
  df_plot$cat <- ordered(df_plot$cat, levels = c("Outcome", "Indicator", "Cause", "Protective"))
  
  write_yaml(df_plot$Word, "s2_words.yml")
  
  
  p <- ggplot(df_plot, aes(y = Word, x = Frequency)) +
    geom_segment(aes(x = 0, xend = Frequency,
                     y = Word, yend = Word, linetype = faded), colour = "grey50"
    ) + 
    geom_vline(xintercept = 0, colour = "grey50", linetype = 1) + xlab("Word frequency") +
    geom_point(data = df_plot[df_plot$faded, ], aes(colour = cat), fill = "white", shape = 21, size = 1.5) +
    geom_point(data = df_plot[!df_plot$faded, ], aes(colour = cat, fill = cat), shape = 21, size = 1.5) +
    scale_colour_manual(values = c(Outcome = "gray50", Indicator = "tomato", Cause = "gold", Protective = "forestgreen"), guide = NULL)+
    scale_fill_manual(values = c(Outcome = "gray50", Indicator = "tomato", Cause = "gold", Protective = "forestgreen")) +
    scale_x_log10() +
    scale_linetype_manual(values = c("TRUE" = 2, "FALSE" = 1), guide = NULL) +
    theme_bw() + theme(panel.grid.major.x = element_blank(),
                       panel.grid.minor.x = element_blank(), axis.title.y = element_blank(),
                       legend.position = c(.70,.125),
                       legend.title = element_blank(),
                       axis.text.y = element_text(hjust=0, vjust = 0, size = 6))
  
  svg("s2_varimp.svg", width = 7/2.54, height = 14/2.54)
  eval(p)
  dev.off()
  
  ggsave("s2_varimp.png", p, device = "png", width = 7, height = 14, units = "cm")
}

# Co-occurrence -----------------------------------------------------------
set.seed(5646)
cooc <- select_cooc(create_cooc(dtm_top), q = .975)

if(run_everything){
  write.csv(as.matrix(cooc), "s2_cooc.csv")
  df_plot <- as_cooccurrence(cooc)
  df_plot <- df_plot[!df_plot$term1 == df_plot$term2, ]
  df_plot <- df_plot[order(df_plot$cooc, decreasing = TRUE), ]
  
  df_plot$id <- apply(df_plot[, c("term1", "term2")], 1, function(x)paste0(sort(x), collapse = ""))
  df_plot <- df_plot[!duplicated(df_plot$id), ]
  
  # Create network ----------------------------------------------------------
  
  edg <- df_plot
  edg$width = edg$cooc
  
  vert <- data.frame(name = names(topterms), label = pretty_words(names(topterms)), size = topterms)
  vert <- vert[vert$name %in% unique(c(edg$term1, edg$term2)), ]
  
  categ <- read.csv("study1_categorization.csv", stringsAsFactors = FALSE)
  if(any(!vert$name %in% categ$name)){
    write.table(vert$name[!vert$name %in% categ$name], "clipboard", sep = "\n", row.names = FALSE, col.names= FALSE)
    stop("Please re-categorize missing vertices.")
  } 
  vert$Category <- categ$category[match(vert$name, categ$name)]
  vert$faded <- vert$name %in% baseline
  
  cat_cols <- c(Outcome = "gray50", Indicator = "tomato", Cause = "gold", Protective = "olivedrab2")
  vert$color <- cat_cols[vert$Category]
  vert$frame.color <- cat_cols[vert$Category]

  vert$color[vert$faded] <- "#FFFFFF"
  
  
  vert$size <- scales::rescale(log(vert$size), c(4, 12))
  g <- graph_from_data_frame(edg, vertices = vert,
                             directed = FALSE)
  
  # edge thickness
  E(g)$width <- scales::rescale(sqrt(E(g)$width), to = c(.2, 8))
  dysreg_vertex = which(names(V(g)) == "dysregulation")
  
  edge.start <- ends(g, es=E(g), names = FALSE)[,1]
  edge.end <- ends(g, es=E(g), names = FALSE)[,2]
  # Color edges based on origin:
  #E(g)$color <- V(g)$color[edge.start]
  E(g)$lty <- c(1, 5)[(!(edge.start == dysreg_vertex|edge.end == dysreg_vertex))+1]
  
  set.seed(5) #4 #2 #3
  l1 <- l <- layout_with_fr(g)
  set.seed(3) #64
  l2 <- layout_in_circle(g, order = shifter(V(g), -1))
  
  p <- quote({
    # Set margins to 0
    par(mar=c(0,0,0,0),
        mfrow=c(1,2))
    plot(g, edge.curved = 0, layout=l1,
         vertex.label.family = "sans",
         vertex.label.cex = 0.8,
         vertex.shape = "circle2",
         #vertex.frame.color = 'gray40',
         vertex.label.color = 'black',      # Color of node names
         vertex.label.font = 1,         # Font of node names
         vertex.frame.width = 2
    )
    legend(x=-1.1, y=1.1, names(cat_cols), pch=21, col="#777777", pt.bg=cat_cols, pt.cex=2, cex=.8, bty="n", ncol=1)
    plot(g, edge.curved = 0, layout=l2,
         vertex.label.family = "sans",
         vertex.label.cex = 0.8,
         vertex.shape = "circle2",
         #vertex.frame.color = 'gray40',
         vertex.label.color = 'black',      # Color of node names
         vertex.label.font = 1,         # Font of node names
         vertex.frame.width = 2
    )
  })
  
  # Save files
  png("study2_network1.png", width = 960)
  eval(p)
  dev.off()
  
  svg("study2_network1.svg", width = 14)
  eval(p)
  dev.off()
}

word_freq <- read.csv("study2_word_freq.csv", stringsAsFactors = FALSE)
word_graph <- read.csv("s2_cooc.csv", row.names = 1)
notingraph <- word_freq$Word[!word_freq$Word %in% row.names(word_graph)]
notingraph <- categ[categ$name %in% notingraph, ]
cats <- unique(notingraph$category)
notingraph <- lapply(cats, function(x){ 
  out <- notingraph$name[notingraph$category == x]
  out <- pretty_words(out)
  paste0(paste0("*", out[-length(out)], "*", collapse = ", "), ", and *", tail(out, 1), "*")
})
names(notingraph) <- cats
lda_dims_2 <- read_yaml("Study2_lda_dims.txt")
