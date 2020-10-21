#!/usr/bin/env bash
#@Adri, what's the difference between that first line and #!/bin/bash ?

log_dir="/media/data/data/company/PISA_2021/FIELD_TRIAL/99_Automation/01_util/omt_bash/mk_rec_omtprj/logs"
now=`date "+%Y%m%d_%H%M%S"`
log_file="log_${now}.txt"

find $log_dir -type f -empty -delete

bash /media/data/data/company/PISA_2021/FIELD_TRIAL/99_Automation/01_util/omt_bash/mk_rec_omtprj/mk_rec_omtprj.sh &> $log_dir/$log_file
