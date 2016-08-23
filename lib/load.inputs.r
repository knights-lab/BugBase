# Loads the user-inputs and makes sure they are valid
# Required: otu table, mapping file,
# Optional: map column, groups
# Returns: loaded otu_table, mapping file

"load.inputs" <- function(otu_table, map=NULL, map_column=NULL, groups=NULL){

	#check for an otu table
	if(is.null(otu_table)){
		stop("\nError: No otu table specified.\n")
	}

	#determine file type of otu table (json .biom or .txt)
	otu_ext <- tail(strsplit(otu_table, ".", fixed=T)[[1]], n=1)
	
	#otu_table is otus x samples
	if(otu_ext == "txt"){
		otu_table <- as.matrix(read.table(otu_table, sep='\t', head=T, row=1, 
												check=F, comment='', skip=1))
	} else {
		if(otu_ext == "biom"){
			otu_table <- as.matrix(biom_data(read_biom(otu_table)))
			} else {
				stop("\nError: otu table must be either .txt or .biom (json)\n")
			}
	}
	
	if(is.null(map)){
		cat("\nNo mapping file was specified. All samples will be predicted.\n")
	} else {
		#map is samples x metadata
		map <- read.table(map,sep='\t',head=T,row=1,check=F,comment='')
		
		if(is.null(map_column)){
			stop("\nError: No map column specified. To run BugBase without a mapping file use '-a'\n")
		}
		
		if(! map_column %in% colnames(map)){
			cat("\nError: Map column specified does not exist\n")
			cat("\nThe map columns available are:\n")
			cat(colnames(map),"\n\n")
			stop("\nError listed above\n")
		}
		
		#print the number of samples matching between the otu table and map
		# cat("\nThe number of samples matching between the otu table and mapping file:")
		# cat("\n",length(intersect(rownames(map),colnames(otu_table)))[1],"\n")

		#define treatment groups
		if(is.null(groups)){
			groups <- unique(map[,map_column])
			groups <- lapply(groups, as.character)
			if(length(groups) <= 1){
				stop("\nError: a minimum of two groups must be tested\n")
			}
		} else {
			#use user-defined groups
			groups <- strsplit(groups, ",")[[1]]
			#remove any duplicates
			groups <- unique(groups)
			if(length(groups) <= 1){
				stop("\nError: a minimum of two groups must be tested\n")
			}
			#define the groups that exist in that mapping column
			groups_avail <- unique(map[,map_column])
			#check is groups specified exist
			for(g in groups){
				if(! g %in% groups_avail){
					cat("\nError:\n")
					cat(g," ")
					cat("is not a group listed in the mapping file.\n")
					cat("These are the groups available:\n")
					cat(groups_avail,"\n\n")
					stop("\nError listed above\n")
				}
			}
		}

		#factor groups so they appear in user-listed order
		map[,map_column] <- factor(map[,map_column],groups)
		
		#get indices of which rows to keep
		ix.keep <- map[,map_column] %in% groups
		#keep only subset of samples belonging to requested groups
		new_map <- droplevels(as.data.frame(map[ix.keep,]))

		#keep only samples that intersect between the map and otu table
		intersect_btwn <- intersect(rownames(map),colnames(otu_table))
		new_map <- map[intersect_btwn,]
		new_otu <- droplevels(as.data.frame(otu_table[,intersect_btwn]))
		
		#print the groups to be tested
		# cat("\nThe number of samples in each group are:")
		# print(table(new_map[,map_column]))
		# map <- new_map
		# otu_table <- new_otu
	}
	
	return(list(
		otu_table=otu_table,
		map=map,
		groups=groups,
		map_column=map_column))
}

