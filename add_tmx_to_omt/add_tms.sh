#!/usr/bin/env bash

# @date:        2021-04-02
# @authorship:  @msoutopico

# purpose:      Add TMX files from exiting TM folder to an OMT package, initially conceived for FLASH

# call the script as:
# bash add_tms.sh -v $ver -a $assets_path -p $omtpkg_path

# functions
die() { echo "$*" 1>&2 ; exit 1; }

# arguments
# ref: https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
while getopts ":v:a:p:" opt; do
  case "${opt}" in
    v) # version
		ver=${OPTARG}
		;;
    a) # path to assets dir
		assets_path=${OPTARG}
		;;
    p) # path to omt package
		omtpkg_path=${OPTARG}
		;;
  esac
done

if [ -z $ver ]; then die "Kaboom: provide ver name with argument -v"; fi
if [ -z $assets_path ]; then die "Kaboom: provide assets_path name with argument -a"; fi
if [ -z $omtpkg_path ]; then die "Kaboom: provide omtpkg_path name with argument -p"; fi

# for testing
#ver="fra-BEL" && omtpkg_path="/media/data/data/company/IPSOS/EUROBAROMETER_FLASH_2.0/08_FLASH_PROJECTS/FLASH-002/02_ADA/${ver}/03_From_Adaptor/Eurobarometer_FLASH-002_${ver}_OMT.omt"
#omtpkg_path="/media/data/data/company/IPSOS/EUROBAROMETER_FLASH_2.0/08_FLASH_PROJECTS/FLASH-002/02_ADA/${ver}/03_From_Adaptor/Eurobarometer_FLASH-002_${ver}_OMT.omt"
#assets_path="/media/data/data/company/IPSOS/EUROBAROMETER_FLASH_2.0/09_ASSETS/01_Incoming"

path_to_langtags_csv="/media/data/data/company/cApStAn_Tech/20_Automation/Scripts/cli_automation/flash_prepp_help/config/langtags_20210228.csv"

omtdir_path="${omtpkg_path/.omt/}"
omtpkg=$(basename -- $omtpkg_path)
omtdir=$(basename -- $omtdir_path)
parentdir="$(dirname "$omtpkg_path")"
#omtdir=$(echo $omtpkg | cut -f 1 -d '.omt')
echo $ver
echo $omtpkg_path
echo $omtdir_path
echo $omtpkg
echo $omtdir

echo "Get omt_tag"
if grep -q $ver $path_to_langtags_csv; then omt_tag=$(grep $ver $path_to_langtags_csv | cut -d, -f5 | xargs); fi

# make object with all names and paths of OmegaT project ??

if [ -e $omtpkg_path ]; then

	echo "Unzip project package"
	unzip -d $omtdir_path $omtpkg_path
	echo "Archive project package in _bak"
	if [ ! -e $parentdir/_bak ]; then mkdir $parentdir/_bak; fi
	mv $omtpkg_path $parentdir/_bak

	echo "Traverse TMX files for version"
	for tmx in $(find $assets_path -name *$ver*.tmx); do
		echo "Remove base files from $omtdir_path/tm/enforce";
		rm $omtdir_path/tm/enforce/*
		echo "Add asset $tmx to $omtdir_path/tm/enforce";
		cp $tmx $omtdir_path/tm/enforce
	done

	echo "Traverse TMX files for version (OmegaT tag)"
	for tmx in $(find $assets_path -name *$omt_tag*.tmx); do
		echo "Add asset $tmx to $omtdir_path/tm/enforce";
		cp $tmx $omtdir_path/tm/enforce
	done

	echo "Go inside the project folder"
	pushd $omtdir_path
	echo "Zip project"
	zip -r ../$omtpkg *
	echo "Come back"
	popd
	echo "Remove project folder"
	rm -r $omtdir_path
	echo "===================================================="

else
	echo "Project package $omtpkg not found, unable to proceed "
fi


#bash add_tms_to_omtpkg.sh -v $ver -a $path_to_incoming_assets_dir -p $omtpkg_path
