#!/bin/bash

# must be calledas:
# bash [this_script].sh -d /path/to/folder/containing/all/version/folders

# ref: https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
while getopts d: flag
do
    case "${flag}" in
        d) dir=${OPTARG};;
    esac
done

cd $dir
# cd /media/data/data/company/PISA_2021/FIELD_TRIAL/_Global_Crises_Module/0_Central_translation/01_Translate_workflows

#path_to_prop_tmpls="/media/data/data/company/PISA_2021/PISA_2021/FIELD_TRIAL/99_Automation/01_util/omt_bash/mk_rec_omtprj/_tmpl/proj_props.txt"
if [ ! -f "proj_props.txt" ]
then
    # that defines variables t1_dir, t2_dir, rec_dir, t1_pkg_tmpl, t2_pkg_tmpl, t1_tmx_tmpl, t2_tmx_tmpl
    while read -r line; do declare "$line"; done < proj_props.txt
else
    echo "No properties file found"
    exit 1
fi

if [ ! -v t1_dir ] || [ ! -v t2_dir ] || [ ! -v rec_dir ] || [ ! -v t1_pkg_tmpl ] || [ ! -v t2_pkg_tmpl ] || [ ! -v t1_tmx_tmpl ] || [ ! -v t2_tmx_tmpl ]
then
    exit 1
fi

#apps="/mnt/c/Apps/"
#util="/mnt/c/Apps/Util"
#util="/media/data/data/company/PISA_2021/FIELD_TRIAL/99_Automation/01_util"

#omtjar="/mnt/c/Program Files/OmegaT/OmegaT.jar"    #v4
omtjar="/opt/omegat/OmegaT_4.2.0/OmegaT.jar"        #v4
#omtjar="${apps}/OmegaT_5.3.0/OmegaT.jar"
#omtjar="${apps}/OmegaT_5.2.0/OmegaT.jar" #/opt/omegat/OmegaT.jar

#omt_config="/mnt/c/Users/souto/AppData/Roaming/OmegaT"
omt_config="/home/ad/.capstan/config"
omt_plugin="plugin-omt-package-1.6.3.jar"

for ver in $(ls -d *)
do

    t1_prj_pkg="${t1_pkg_tmpl/lll-CCC/$ver}"
    t2_prj_pkg="${t2_pkg_tmpl/lll-CCC/$ver}"
    t1_tmx="${t1_tmx/lll-CCC/$ver}"
    t2_tmx="${t2_tmx/lll-CCC/$ver}"
    rec_prj_pkg="${t2_prj_pkg/_Translator2.omt/.omt}"

    # reconclation for this version = if the reconciliation folder exists
	rec_for_ver="$ver/$rec_dir"

	path_to_t1_pkg="$ver/$t1_dir/$t1_prj_pkg"
	path_to_t2_pkg="$ver/$t2_dir/$t2_prj_pkg"
	path_to_rec_pkg="$ver/$rec_dir/$rec_prj_pkg"

	if [ -d "$rec_for_ver" ]
	then
		#echo $ver
		if [ ! -f $path_to_rec_pkg ]
		then
			if [ -f $path_to_t1_pkg ] && [ -f $path_to_t2_pkg ]
			then
				echo "========================================================================"
				echo ">> ${ver}: The OmegaT package for reconciliation will be created"
				echo ">> ${ver}: both T1 and T2 omt packages exist"

				echo ">> ${ver}: unpack T1 in $rec_dir folder"
				#t1_prj_pkg=$(basename -- $path_to_t1_pkg) # DEFINED IN PROPERTIES
				t1_prj_dir=$(echo $t1_prj_pkg | cut -f 1 -d '.')
				#t1_prj_dir="${t1_prj_pkg%.*}"
				unzip -d $ver/$rec_dir/$t1_prj_dir $path_to_t1_pkg
				echo ">> ${ver}: run omegat on T1 proj"
				java -jar "$omtjar" "$ver/$rec_dir/$t1_prj_dir" --mode=console-translate
				#echo ">> flush /tm"
				#rm -r $ver/$rec_dir/$t1_prj_dir/tm/*
				mkdir $ver/$rec_dir/$t1_prj_dir/tm/03_rec
				#echo ">> ${ver}: move T1's master TM to t1/tm/03_rec"
				echo ">> ${ver}: move ${t1_prj_dir}-omegat.tmx from $ver/$rec_dir/$t1_prj_dir/ to $ver/$rec_dir/$t1_prj_dir/tm/03_rec"
				mv $ver/$rec_dir/$t1_prj_dir/${t1_prj_dir}-omegat.tmx $ver/$rec_dir/$t1_prj_dir/tm/03_rec/$t1_tmx
				echo ">> ${ver}: flush working TM"
				rm -r $ver/$rec_dir/$t1_prj_dir/omegat/project_save.tmx*

				echo ">> ${ver}: unpack T2 here"
				#t2_prj_pkg=$(basename -- $path_to_t2_pkg) # DEFINED IN PROPERTIES
				t2_prj_dir=$(echo $t2_prj_pkg | cut -f 1 -d '.')
				#t2_prj_dir="${t2_prj_pkg%.*}"
				unzip -d $ver/$rec_dir/$t2_prj_dir $path_to_t2_pkg
				echo ">> ${ver}: run omegat on T2 proj"
				java -jar "$omtjar" "$ver/$rec_dir/$t2_prj_dir" --mode=console-translate
				echo ">> ${ver}: move ${t2_prj_dir}-omegat.tmx from $ver/$rec_dir/$t2_prj_dir/ to $ver/$rec_dir/$t1_prj_dir/tm/03_rec"
				mv $ver/$rec_dir/$t2_prj_dir/${t2_prj_dir}-omegat.tmx $ver/$rec_dir/$t1_prj_dir/tm/03_rec/$t2_tmx


				echo ">> ${ver}: pack and rename T1"
				java -cp "$omtjar":"$omt_config"/plugins/"$omt_plugin" net.briac.omegat.plugin.omt.ManageOMTPackage --config "$omt_config"/omt-package-config.properties "$ver/$rec_dir/$t1_prj_dir" "$path_to_rec_pkg"

				echo ">> ${ver}: remove t1 and t2 folders"
				rm -r "$ver/$rec_dir/$t2_prj_dir" "$ver/$rec_dir/$t1_prj_dir"
			#else
				#echo ">> ${ver}: The project packages for T1 or T2 (or both) have not arrived yet"
			fi
		#else
			#echo ">> ${ver}: The OmegaT package for reconciliation already exists"
		fi
	fi
done
