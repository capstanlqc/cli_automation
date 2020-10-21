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

	rec_dir="$ver/03_reconciler"
	path_to_t1_pkg="$ver/01_translator_1/PISA2021FT_${ver}_OMT_Questionnaires_GCM_T*1.omt"
	path_to_t2_pkg="$ver/02_translator_2/PISA2021FT_${ver}_OMT_Questionnaires_GCM_T*2.omt"
	path_to_rec_pkg="$ver/03_reconciler/PISA2021FT_${ver}_OMT_Questionnaires_GCM.omt"

	if [ -d "$rec_dir" ]
	then
		#echo $ver
		if [ ! -f $path_to_rec_pkg ]
		then
			if [ -f $path_to_t1_pkg ] && [ -f $path_to_t2_pkg ]
			then
				echo "========================================================================"
				echo ">> ${ver}: The OmegaT package for reconciliation will be created"
				echo ">> ${ver}: both T1 and T2 omt packages exist"

				echo ">> ${ver}: unpack T1 in 03_reconciler folder"
				t1_prj_pkg=$(basename -- $path_to_t1_pkg)
				t1_prj_dir=$(echo $t1_prj_pkg | cut -f 1 -d '.')
				#t1_prj_dir="${t1_prj_pkg%.*}"
				unzip -d $ver/03_reconciler/$t1_prj_dir $path_to_t1_pkg
				echo ">> ${ver}: run omegat on T1 proj"
				java -jar "$omtjar" "$ver/03_reconciler/$t1_prj_dir" --mode=console-translate
				#echo ">> flush /tm"
				#rm -r $ver/03_reconciler/$t1_prj_dir/tm/*
				mkdir $ver/03_reconciler/$t1_prj_dir/tm/03_rec
				#echo ">> ${ver}: move T1's master TM to t1/tm/03_rec"
				echo ">> ${ver}: move ${t1_prj_dir}-omegat.tmx from $ver/03_reconciler/$t1_prj_dir/ to $ver/03_reconciler/$t1_prj_dir/tm/03_rec"
				mv $ver/03_reconciler/$t1_prj_dir/${t1_prj_dir}-omegat.tmx $ver/03_reconciler/$t1_prj_dir/tm/03_rec/PISA_${ver}_GCM_Translator1.tmx
				echo ">> ${ver}: flush working TM"
				rm -r $ver/03_reconciler/$t1_prj_dir/omegat/project_save.tmx*

				echo ">> ${ver}: unpack T2 here"
				t2_prj_pkg=$(basename -- $path_to_t2_pkg)
				t2_prj_dir=$(echo $t2_prj_pkg | cut -f 1 -d '.')
				#t2_prj_dir="${t2_prj_pkg%.*}"
				unzip -d $ver/03_reconciler/$t2_prj_dir $path_to_t2_pkg
				echo ">> ${ver}: run omegat on T2 proj"
				java -jar "$omtjar" "$ver/03_reconciler/$t2_prj_dir" --mode=console-translate
				echo ">> ${ver}: move ${t2_prj_dir}-omegat.tmx from $ver/03_reconciler/$t2_prj_dir/ to $ver/03_reconciler/$t1_prj_dir/tm/03_rec"
				mv $ver/03_reconciler/$t2_prj_dir/${t2_prj_dir}-omegat.tmx $ver/03_reconciler/$t1_prj_dir/tm/03_rec/PISA_${ver}_GCM_Translator2.tmx

				echo ">> ${ver}: add new text file"
				cp ../01_added_item/ZZ_TVRadio.txt $ver/03_reconciler/$t1_prj_dir/source

				echo ">> ${ver}: pack and rename T1"
				java -cp "$omtjar":"$omt_config"/plugins/"$omt_plugin" net.briac.omegat.plugin.omt.ManageOMTPackage --config "$omt_config"/omt-package-config.properties "$ver/03_reconciler/$t1_prj_dir" "$path_to_rec_pkg"

				echo ">> ${ver}: remove t1 and t2 folders"
				rm -r "$ver/03_reconciler/$t2_prj_dir" "$ver/03_reconciler/$t1_prj_dir"
			#else
				#echo ">> ${ver}: The project packages for T1 or T2 (or both) have not arrived yet"
			fi
		#else
			#echo ">> ${ver}: The OmegaT package for reconciliation already exists"
		fi
	fi
done
