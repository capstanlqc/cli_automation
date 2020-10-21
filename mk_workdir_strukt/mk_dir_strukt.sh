#!/bin/bash

# requirements:
# a zipped template version folder ending in lll-CCC.zip
# a list of versions in a text Files


# must be called as:
# bash [this_script].sh -d /path/to/folder/containing/all/version/folders

# ref: https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
while getopts d: flag
do
    case "${flag}" in
        d) dir=${OPTARG};;
    esac
done

echo "changing directory to " $dir
cd $dir

ver_dir_tmpl="*lll-CCC.zip"
ver_dir_list="*lll-CCC.txt"

if [ "$ver_dir_tmpl" ] && [ "$ver_dir_list" ]
then
    echo "found template and list"
    for f in `cat $ver_dir_list`; do unzip -d $f $ver_dir_tmpl; chmod -R 775 $f; chgrp -R users $f; done
fi

mkdir _tech
mv $ver_dir_tmpl $ver_dir_list _tech
