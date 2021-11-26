#!/usr/bin/env bash

thismonth=`date "+%Y%m"` # to do nothing
lastmonth=$((`date "+%Y%m"`-1)) # to archive
prevmonth=$((`date "+%Y%m"`-3)) # to delete

cd _log
echo "$(pwd)"
if compgen -G "${lastmonth}*.log" > /dev/null; then
	echo "zip -r _bak/logs_${lastmonth}.zip ${lastmonth}*.log && rm ${lastmonth}*.log"
	zip -r "_bak/logs_${lastmonth}.zip" ${lastmonth}*.log && rm ${lastmonth}*.log	
fi

cd _bak
if compgen -G "logs_${prevmonth}.zip" > /dev/null; then
	rm "logs_${prevmonth}.zip"
fi

if compgen -G "${thismonth}*.log" > /dev/null; then
	: # echo "Do nothing"
fi

echo "========================"