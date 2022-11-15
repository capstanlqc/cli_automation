#!/usr/bin/env bash

path_to_app="/media/data/data/company/cApStAn_Tech/11_WC"
path_to_files="$path_to_app/01_ToAnalyze"

cd $path_to_files

# check whether there are files to analyze, stop if none
files_to_analyze=`ls | wc -l`
if (( $files_to_analyze == 0 )); then echo "No files found" && exit 1; fi

# define project name
timestamp=`date +%Y-%m-%d_%H-%M-%S`

project_relpath="../02_Projects/${timestamp}_OMT"
mkdir $project_relpath
project_abspath=`readlink -f $project_relpath`
cd $project_abspath

# create project
java -jar /opt/omegat/OmegaT_5.4.3/OmegaT.jar team init en xx
# add files
mv $path_to_files/* source
cd -
# create stats
java -jar /opt/omegat/OmegaT_5.4.3/OmegaT.jar $project_abspath --mode=console-translate

# gergoe's suggestion: convert tsv to csv 
cat $project_abspath/omegat/project_stats.txt | sed -E "s/\\s*\\t\\s*/\",\"/g;s/^(.*)$/\"\\1\"/g" > $project_abspath/omegat/project_stats.csv

# convert tsv to xslx
ssconvert $project_abspath/omegat/project_stats.csv --export-type=Gnumeric_Excel:xlsx

# move stats in Excel to 03 folder
cp $project_abspath/omegat/project_stats.xlsx $path_to_app/03_Analyzed/$timestamp.xlsx

# pack project
cd $project_abspath
zip -r ../$timestamp.omt *
cd ..

# remove project folder
rm -r $project_abspath
