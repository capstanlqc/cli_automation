#!/bin/bash

cd /media/data/data/company/PISA_2021/FIELD_TRIAL/_Global_Crises_Module/0_Central_translation/01_Translate_workflows

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

	adap_dir="$ver/03_adaptation"
	path_to_base_pkg="$ver/01_base_version/PISA2021FT_*_OMT_Questionnaires_GCM.omt"
	path_to_init_pkg="$ver/02_initial_pkg/PISA2021FT_${ver}_OMT_Questionnaires_GCM.omt"
	path_to_adap_pkg="$ver/03_adaptation/PISA2021FT_${ver}_OMT_Questionnaires_GCM.omt"

	if [ -d "$adap_dir" ]
	then
		#echo $ver
		if [ ! -f $path_to_adap_pkg ]
		then
			if ([ -f $path_to_base_pkg ] && [ -f $path_to_init_pkg ])
			then
				echo "========================================================================"
				echo ">> ${ver}: The OmegaT package for adaptation will be created"
				echo ">> ${ver}: The base version and the initial package exist"

				echo ">> ${ver}: Unpack base package in 03_adaptation folder"
				base_prj_pkg=$(basename -- $path_to_base_pkg)
				base_prj_dir=$(echo $base_prj_pkg | cut -f 1 -d '.')
				#base_prj_dir="${base_prj_pkg%.*}"
				unzip -d $ver/03_adaptation/$base_prj_dir $path_to_base_pkg
				echo ">> ${ver}: run omegat on base proj"
				java -jar "$omtjar" "$ver/03_adaptation/$base_prj_dir" --mode=console-translate
				#echo ">> flush /tm"

				echo ">> ${ver}: Unpack initial package in 03_adaptation folder"
				init_prj_pkg=$(basename -- $path_to_init_pkg)
				init_prj_dir=$(echo $init_prj_pkg | cut -f 1 -d '.')
				unzip -d $ver/03_adaptation/$init_prj_dir $path_to_init_pkg

				base_auto_dir="$ver/03_adaptation/$init_prj_dir/tm/auto"
				if [ ! -d "$base_auto_dir" ]; then
					mkdir $base_auto_dir
				fi
				#echo ">> ${ver}: move base's master TM to base/tm/03_rec"
				echo ">> ${ver}: move ${base_prj_dir}-omegat.tmx from $ver/03_adaptation/$base_prj_dir/ to $ver/03_adaptation/$init_prj_dir/tm/auto"
				new_base_name=${base_prj_dir/OMT_Questionnaires_GCM/base}
				mv $ver/03_adaptation/$base_prj_dir/${base_prj_dir}-omegat.tmx $base_auto_dir/$new_base_name.tmx

				echo ">> ${ver}: add new text file"
				cp ../01_added_item/ZZ_TVRadio.txt $ver/03_adaptation/$init_prj_dir/source

				echo ">> ${ver}: pack adap project"
				java -cp "$omtjar":"$omt_config"/plugins/"$omt_plugin" net.briac.omegat.plugin.omt.ManageOMTPackage --config "$omt_config"/omt-package-config.properties "$ver/03_adaptation/$init_prj_dir" "$path_to_adap_pkg"

				echo ">> ${ver}: dump base and ini project folders"
				rm -r "$ver/03_adaptation/$init_prj_dir" "$ver/03_adaptation/$base_prj_dir"
			#else
				#echo ">> ${ver}: The project packages for T1 or T2 (or both) have not arrived yet"
			fi
		#else
			#echo ">> ${ver}: The OmegaT package for adaptation already exists"
		fi
	fi
done
