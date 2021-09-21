#!/usr/bin/env bash

# set up the logs
#APP_ROOT="$( dirname "$(readlink -f -- "$0")" )" # always relative parent dir to the script
APP_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#echo "Getting paths from $APP_ROOT/paths.txt"
while read -r line; do declare $line; done < "$APP_ROOT/paths/config.txt"
roots=$(cat "$APP_ROOT/paths/roots.txt") 

log_dir=$APP_ROOT/_log
#log_file="${now}_bash.log"
log_file="bash_log.txt"

for root in $roots; do

	now=`date "+%Y%m%d_%H%M%S"`
	config="${root}/02_AUTOMATION/Config/config.xlsx"
	init_dir="${root}/02_AUTOMATION/Initiation"

	# remove emtpy reports
	find $log_dir -type f -empty -delete

	echo "${now} @launcher.sh - Changing directory to the working folder ($APP_ROOT)" >> $log_dir/$log_file
	#cd $cwd
	cd $APP_ROOT
	init=NULL

	# grab init bundle path if it exists
	for init_zip_path in $(find $init_dir -maxdepth 1 -name *.zip -type f)
	do
		init="$init_zip_path"
		#echo "pipenv run python3 mk_workflows.py -i $init -c $config -m $mapping >> $log_dir/$log_file" 
		echo "${now} @launcher.sh - pipenv run python3 mk_workflows.py -i $init -c $config -m $mapping >> $log_dir/$log_file" >> $log_dir/$log_file
		#pipenv run python $script -i $init -c $config -m $mapping >> $log_dir/$log_file
		pipenv run python mk_workflows.py -i $init -c $config -m $mapping >> $log_dir/$log_file
	done
	sleep 10 # seconds
	echo "${now} ----" >> $log_dir/$log_file
done

echo "${now} @launcher.sh - ------------------------------------------------------"

echo "${now} @launcher.sh - some log cleanup - --------------------------------------------------" >> $log_dir/$log_file
echo "${now} @launcher.sh - changing directory to $APP_ROOT" >> $log_dir/$log_file
cd $APP_ROOT
# check that this script is not running
bash log_cleanup.sh >> $log_dir/$log_file
