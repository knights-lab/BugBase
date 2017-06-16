
## ----packages------------------------------------------------------------
library("biom"); packageVersion("biom")


## ----read-biom-examples--------------------------------------------------
min_dense_file   = system.file("extdata", "min_dense_otu_table.biom", package = "biom")
min_sparse_file  = system.file("extdata", "min_sparse_otu_table.biom", package = "biom")
rich_dense_file  = system.file("extdata", "rich_dense_otu_table.biom", package = "biom")
rich_sparse_file = system.file("extdata", "rich_sparse_otu_table.biom", package = "biom")
min_dense_file   = system.file("extdata", "min_dense_otu_table.biom", package = "biom")
rich_dense_char  = system.file("extdata", "rich_dense_char.biom", package = "biom")
rich_sparse_char  = system.file("extdata", "rich_sparse_char.biom", package = "biom")
x1 = read_biom(min_dense_file)
x2 = read_biom(min_sparse_file)
x3 = read_biom(rich_dense_file)
x4 = read_biom(rich_sparse_file)
x5 = read_biom(rich_dense_char)
x6 = read_biom(rich_sparse_char)
x1


## ----accessor-examples-table---------------------------------------------
biom_data(x1)
biom_data(x2)


## ----matrix-coercion-----------------------------------------------------
as(biom_data(x2), "matrix")


## ----observ-meta---------------------------------------------------------
observation_metadata(x1)
observation_metadata(x2)
observation_metadata(x3)
observation_metadata(x4)[1:2, 1:3]
class(observation_metadata(x4))


## ----plot-examples-------------------------------------------------------
sample_metadata(x1)
sample_metadata(x2)
sample_metadata(x3)
sample_metadata(x4)[1:2, 1:3]
class(sample_metadata(x4))


## ----plot----------------------------------------------------------------
plot(biom_data(x4))
boxplot(as(biom_data(x4), "vector"))
heatmap(as(biom_data(x4), "matrix"))


## ----write-biom-examples-------------------------------------------------
outfile = tempfile()
write_biom(x4, outfile)
y = read_biom(outfile)
identical(x4, y)


## ----compare-files-diff, eval=FALSE--------------------------------------
## # On Unix OSes
## system(paste0("diff ", rich_sparse_file, outfile))
## # On windows
## system(paste0("FC ", rich_sparse_file, outfile))


