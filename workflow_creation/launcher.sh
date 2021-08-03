#!/usr/bin/env bash

# set up the logs
#APP_ROOT="$( dirname "$(readlink -f -- "$0")" )" # always relative parent dir to the script
APP_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#echo "Getting paths from $APP_ROOT/paths.txt"
while read -r line; do declare $line; done < "$APP_ROOT/paths.txt"

now=`date "+%Y%m%d_%H%M%S"`
log_dir=$APP_ROOT/_log
#log_file="${now}_bash.log"
log_file="bash_log.txt"

echo $log_dir
echo $log_file

# remove emtpy reports
find $log_dir -type f -empty -delete

echo "Changing directory to the working folder (the app root)" >> $log_dir/$log_file
cd $cwd
init=NULL

# grab init bundle path if it exists
for init_zip_path in $(find $init_dir -maxdepth 1 -name *.zip -type f)
do
	init="$init_zip_path"
	echo "pipenv run python mk_workflows.py -i $init -c $config -m $mapping >> $log_dir/$log_file" >> $log_dir/$log_file
	#pipenv run python $script -i $init -c $config -m $mapping >> $log_dir/$log_file
	pipenv run python mk_workflows.py -i $init -c $config -m $mapping >> $log_dir/$log_file
done

# call 
#pipenv run python $script -i $init -c $config -m $mapping
#mv $init_zip_path $init_dir/_done # do that in python if init not listed in do_not_archive_bundle


