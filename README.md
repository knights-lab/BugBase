## BugBase Usage and Installation

### Standard Users
Standard users can analyze their microbiome samples with the default phenotypes, as well as the KEGG pathways. 

### Dependencies

Follow the website directions to install:
* R (http://cran.r-project.org)

These R packages can be installed with this command in R: `install.packages(‘package’)`
* ape
* optparse
* beeswarm
* RColorBrewer
* reshape2
* plyr
* grid
* gridExtra
* ggplot2
* biom

### Installation
#### Mac OS
You can download BugBase here, and then add these paths to your `~/.bash_profile` file. This is what is in an example `~/.bash_profile` modification looks like:

```
export BUGBASE_PATH=/Path/to/my/BugBase/
export PATH=$PATH:$BUGBASE_PATH/bin
```

Note: you will need change the paths to match your system and which directory you have downloaded BugBase into. You might need to put it in ~/.bashrc instead of ~/.bash_profile depending on your system. After adding these paths to the .bash_profile or ~/.bashrc, reopen the terminal or login again.

To check your install, type the following in the command line.  It should print the options available to run BugBase.

```
run.bugbase.r -h 
```

### Demo
BugBase comes with a test dataset in the bugbase/doc/data directory. To analyze this data set you would type the following:

```
run.bugbase.r -i $BUGBASE_PATH/doc/data/HMP_s15.txt -m $BUGBASE_PATH/doc/data/HMP_map.txt -c HMPBODYSUBSITE -o output
```

You can view other options with `run.bugbase.r -h`.

### Using BugBase 

BugBase has one main command, `run.bugbase.r`, that will:
-	Normalize your OTU table according to 16S copy number (WGS data will not be normalized)
-	Plot the variance in phenotype possession for thresholds 0-1
-	Determine which threshold to set for each microbiome phenotype
-	Determine the proportion of each microbiome with a given phenotype
-	Plot the proportions of the microbiome with a given phenotype
-	Statistically analyze the microbiome phenotype proportions according the treatment groups specified, or by using regression for continuous data
-	Plot OTU contributions for each phenotype


<dl>
	<dt>Required</dt>
	<dd> -i     input OTU table, picked against the Greengenes database (16S) or IMG (WGS) (.txt or .biom (json))
	<dd> -o     output directory name
	
	<dt>Optional</dt>
	<dd> -w	 	Data is whole genome shotgun data (picked against IMG database)
	<dd> -a 	Plot all samples (no stats will be run)
	<dd> -x		Output prediction files only, no plots will be made
	<dd> -m     mapping file (tab-delimited text file)
	<dd> -c     map column header to plot by (which column denotes treatment groups)
	<dd> -g 	Specify subset of groups in map column to plot (list, comma separated)
	<dd> -z 	Data is of type continuous 
	<dd> -C 	Use covariance instead of variance to determine thresholds
	<dd> -t	 	Taxa level to plot OTU contributions by (number 1-7)
	<dd> -T 	Specify a threshold to use for all traits (number 0-1)
	<dd> -k 	Use the KEGG modules instead of default traits (Note: you must specify which modules!)
	<dd> -p 	List modules or traits to predict (comma separated list, no spaces)
	<dd> -u	 	Use a user-define trait table. Absolute file path must be specified

	
</dl>

### BugBase compatible OTU tables

BugBase takes in QIIME compatible OTU tables in the classic (.txt) or json version (.biom).  Below are some instructions regarding OTU table generation for downstream BugBase use.

16S data:
- Closed reference OTU picking with the Greengenes 97% representative set
- Do not include taxonomy if in the classic form (.txt)
- Counts, not relative abundance

WGS data:
- Closed reference OTU picking with the IMG reference sequences

To generate a BugBase compatible OTU table from WGS data, please follow the steps below:

1. Download the UTree release specific to your operating system by following the first step [here.](https://github.com/knights-lab/UTree "UTree") Stop when you have reached "Compilation", as that step and those following it are not needed for OTU picking purposes.
2. Install NINJA-SHOGUN by following the instruction [here.](https://github.com/knights-lab/NINJA-SHOGUN "SHOGUN") Only complete the initial steps.  Stop when you have reached "Building a Database", as that step and those following it are not needed for OTU picking purposes.
3. Download and unzip the SHOGUN-BugBase database (IMG reference sequences and maps) needed for OTU picking [here.](http://z.umn.edu/bugbaseimgshogun "shogun-bugbase-db")
4. Run OTU picking with the following commands.  Update the `shogun_bugbase` command to be specific to the filepaths for your input sequences and the SHOGUN-BugBase database you downloaded.  Your input sequences should be in one directory, with one .fna file per sequence. The name of each .fna file should be the name of the sample it corresponds to. Once OTU picking is complete, you will have an OTU table in classic format (.txt) called 'taxa_counts.txt' within the output directory specified.
```
source activate shogun      #activate the shogun environment

shogun_bugbase -i path_to_sequences -o output_path -u path_to_shogun_bugbase_db      #run OTU picking with shogun

source deactivate     #deactivate the shogun environment
```


=======
