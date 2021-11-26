#!/usr/bin/env bash

# author: 	@msoutopico
# version:	1.0.0
# date: 	2021.11.19

# instructions:

# 1. Put OMT packages and XLIFF files directly in the folder of your preferences
# 2. Get the path to that folder (i.e. path/to/folder)
# 3. Run script as:

# bash replace_emptyxlat_with_space_in_xliff.sh path/to/folder


abs_path=$( readlink -f "$1" )
if [ ! -d "$abs_path/_done" ]; then mkdir "$abs_path/_done"; fi
done_dir=$( readlink -f "$abs_path/_done" )

# functions
die () { echo "$*" 1>&2 ; exit 1; }

write_log () {
	timestamp=$(date +"%Y-%m-%d %H:%M:%S")
	dir="$1"
	msg="$timestamp: $2"
	echo $msg >> $dir/log.txt
}

translate_with_nbsp () {
	# this function will replace an empty or normal space translation with a couple of non-breaking spaces
	file="$1"
	perl -pi -e 's~(?<=xml:space=.)default~preserve~g' "$file"

	if (( `grep -P '>\s*</target>' $xlf | wc -l` > 0 ))
	then
		perl -pi -e 's~(?<=>)\s*(?=</target>)~  ~g' "$file"
		write_log $abs_path "Tweaking $file"; 
	fi
}


# logic

# do it in OMT packages
cd "$abs_path"
for pkg in $(find . -name "*.omt")
do
	if [[ "$pkg" == *"_done"* ]]; then continue; fi

	write_log $abs_path "Analyzing $pkg"
	pkg_name=$(basename -- "$pkg")
	#fextn="${pkg_name##*.}"
	dir_name="${pkg_name%.*}"
	
	if [ -d "$dir_name" ]; then rm -r $dir_name && write_log $abs_path "Removed $dir_name"; fi
	unzip -qq -d $dir_name $pkg_name

	for xlf in $(find "$dir_name/source" -name "*.xlf")
	do
		translate_with_nbsp $xlf
	done

	rm $pkg_name
	cd $dir_name
	zip -qq -r ../$pkg_name *
	cd ..
	rm -r "$dir_name"
	mv $pkg_name "$done_dir"
done

# do it in XLIFF files 
cd "$abs_path"
for xlf in $(find . -name "*.xlf")
do
	if [[ "$xlf" == *"_done"* ]]; then continue; fi
	translate_with_nbsp $xlf
	mv $xlf "$done_dir"
done

echo "Done"
