#!/usr/bin/env bash

#  This script is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with cApps.  If not, see <https://www.gnu.org/licenses/>.

# ############# AUTHORSHIP INFO ###########################################

# __author__ = "Adrien Mathot, Manuel Souto Pico"
# __copyright__ = "Copyright 2022, cApps/cApStAn"
# __license__ = "GPL"
# __version__ = "0.2.0"
# __maintainer__ = "Manuel Souto Pico"
# __email__ = "manuel.souto@capstan.be"
# __status__ = "Testing"


# run as:
# bash /path/to/mk_pisa22-ms-cg-ada_omtprjs.sh /path/to/work_folder

# functions
die() { echo "$*" 1>&2 ; exit 1; }

function write_to_file() {
	#touch $2
	echo $1 >> $2
}

# error output
output=()
now=$(date +"%Y-%m-%d %T")

# use only linebreak as file separator
OIFS="$IFS"
IFS=$'\n'

# conventions:
# path to file = file_path
# filename = file


# paths
#work_folder="/media/data/data/company/PISA_2021/MAIN_SURVEY/02_MS_Coding_Guides/02_New_Math/02_Prepp/03_ZZZ_to_national"
work_folder=$( readlink -f "$1" ) # only argument

# test argument
if test $# -eq 0 || test -z "$1" || test ! -d $work_folder
then
    die "No argument(s) supplied or path not found."
fi

version_list="$work_folder/versions.txt"
tech_folder="$work_folder/_tech"

ft_national_pkgs="$work_folder/IN_FT_NATIONAL"
ms_base_zzz_pkgs="$work_folder/IN_MS_BASE_ZZZ"
cog_national_pkgs="$work_folder/IN_COG_NATIONAL"
ms_national_pkgs="$work_folder/OUT_MS_NATIONAL"

ft_national_prjs="$tech_folder/IN_FT_NATIONAL"
ms_base_zzz_prjs="$tech_folder/IN_MS_BASE_ZZZ"
cog_national_prjs="$tech_folder/IN_COG_NATIONAL"
ms_national_prjs="$tech_folder/OUT_MS_NATIONAL"
mkdir -p $ms_national_prjs


# tests (abs paths)
if test ! -d $work_folder || test ! -d $ft_national || test ! -d $ms_base_zzz || test ! -d $ms_national
then
    die "Some expected folders are not found"
fi

if test -f $work_folder/stopped.status
then
    die "The process is not running. Delete file stopped.status to let it run."
fi

#### For each base package and FT national package: 
#### 1.	Unzip it.
#### 2.	Console-translate the project to generate the master TMs.

# get langtags data
langtags=$(curl --silent -X GET https://capps.capstan.be/langtags_json.php)

# unpack input projects
pkgs_paths=( $ft_national_pkgs $ms_base_zzz_pkgs $cog_national_pkgs )
for pkg_path in "${pkgs_paths[@]}"
do
    # create the folder where projects will be unpacked
    prjs_path="$(dirname "$pkg_path")/_tech/$(basename "$pkg_path")" && mkdir -p $prjs_path

    cd $pkg_path
    for pkg in $(ls *.omt)
    do
        # unpack and console-translate every project if it has not been done
        prj="${pkg%.omt}"
        if test ! -e $prjs_path/$prj
        then
            unzip -d $prjs_path/$prj $pkg_path/$pkg
            output+=("$now: ☆ Unpacked $pkg")
            java -jar /opt/omegat/OmegaT_4.3.2_Linux_64/OmegaT.jar $prjs_path/$prj --mode=console-translate
            # echo "Running OmegaT on $prj went fine" #debug
            output+=("$now: ☆ Ran OmegaT on $prj")
        fi
    done
done

output+=("$now: I ❤️ OmegaT")

cd $work_folder
if test -e $work_folder/versions.txt
# echo "versions.txt exist" #debug
output+=("$now: ☆ File versions.txt exist")
then
	for pisa_code in $(cat versions.txt)
    do
        #echo "$now: 👉 Handling $pisa_code" #debug
        output+=("-----------------------------")
        output+=("$now: 👉 Handling $pisa_code")
        # get omegat code
        convention="PISA"
        omegat_code=$(echo $langtags | jq -cr --arg CODE "$pisa_code" --arg CONV "$convention" 'map(select(.[$CONV] == $CODE))'[].OmegaT)

        # get language subtag
        pisa_lang=$(cut -d "-" -f1 <<< "$pisa_code")
        omt_lang=$(cut -d "-" -f1 <<< "$omegat_code")
        # region=$(cut -d "-" -f2 <<< "$pisa_code") # not neeeded 

        # copy base project and tweak it to create the new project
        if test -e $ms_base_zzz_prjs/*$pisa_lang* # glob
        then
            if test "$(find $ms_base_zzz_pkgs -name "*$pisa_lang*" | wc -l)" == "1"
            then
                pkg_path=$(find $ms_base_zzz_pkgs -name "*$pisa_lang*")
                zzz_pkg=$(basename "$pkg_path")

                # echo "Only one base project has been found for $pisa_lang, we can proceed" #debug
                output+=("$now: ☆ One (only) base project has been found for ${pisa_lang}-ZZZ, we can proceed: $zzz_pkg")
                
                # rename the MS national project, replacing ZZZ with the region subtag (e.g. COL) in the folder name: esp-ZZZ -> esp-COL
                ms_national_pkg="${zzz_pkg/${pisa_lang}-ZZZ/"$pisa_code"}"
                ms_national_prj="${ms_national_pkg%.omt}"
                
                # if test ! -e $ms_national_prjs/$ms_national_prj
                if test ! -e $ms_national_pkgs/$ms_national_pkg
                then
                    # echo "unzip -d $ms_national_prjs/$ms_national_prj $pkg_path > /dev/null 2>&1" #debug
                    # output+=("$now: ☆ Unzipped -d $ms_national_prjs/$ms_national_prj $pkg_path")
                    unzip -d $ms_national_prjs/$ms_national_prj $pkg_path > /dev/null 2>&1
                    # echo "Unzipped $pkg_path" #debug

                    # update the target_lang value in the project settings of the MS national project, 
                    # replacing es-ZZ or zh-ZZ in the project settings with the omegat tag in the ms_national_prj, e.g. es-ZZ -> es-CO
                    perl -pi -e "s/(?<=target_lang>)\w+-ZZ/$omegat_code/" $ms_national_prjs/$ms_national_prj/omegat.project

                    # delete all TMX files from /tm and /tm/auto in the MS national project and other unnecessary files
                    rm -r $ms_national_prjs/$ms_national_prj/omegat/project_save.tmx*
                    rm -r $ms_national_prjs/$ms_national_prj/omegat/*.txt
                    rm -r $ms_national_prjs/$ms_national_prj/omegat/*.properties
                    rm -r $ms_national_prjs/$ms_national_prj/omegat/*.log
                    rm -r $ms_national_prjs/$ms_national_prj/tm/auto/*ZZZ*.tmx

                    ### ONLY CONTINUE IF THE FT NATIONAL PROJECT IS AVAILABLE
                    counter=$(find $ft_national_prjs -name "*$pisa_code*" -type d | wc -l)
                    #counter=$(ls $ft_national_prjs | grep $pisa_code | wc -l)
                    
                    if test "$counter" -eq 0; then
                        output+=("$now: ❌ FT national project(s) for $pisa_code not available, nothing to do!")
                        rm -r $ms_national_prjs/$ms_national_prj
                        continue
                    fi

                    output+=("$now: ☆ pisa_code: $pisa_code")
                    output+=("$now: ☆ omegat_code: $omegat_code")
                    
                    # copy the -omegat.tmx master TM from the FT national project folder to /tm/auto/ in the MS national project 
                    # and rename it as PISA2021FT_CG_xxx-XXX.tmx
                    for prj_path in $(find $ft_national_prjs -name "*${pisa_code}*" -type d)
                    do
                        p=$(basename "$prj_path")
                        output+=("$now: ☆ Added FT national TM from $p")
                        # PISA2022MS_CodingGuide_MAT-New_esp-ZZZ_en_OMT-omegat.tmx
                        short_name="${p/CodingGuide/CG}"
                        short_name="${short_name/_en_OMT.tmx/.tmx}"
                        short_name="${short_name/_OMT.tmx/.tmx}"
                        cp $prj_path/$p-omegat.tmx $ms_national_prjs/$ms_national_prj/tm/auto/$short_name.tmx
                    done      

                    # copy the -omegat.tmx master TM from the base/ZZZ project folder 
                    # to /tm folder of the MS national project and rename as esp-ZZZ_CG-MS.tmx or zho-ZZZ_CG-MS.tmx
                    # and to /tm/tmx2source/ in the MS national project and rename it as ES-MS.tmx or ZH-MS.tmx accordingly
                    
                    mkdir -p $ms_national_prjs/$ms_national_prj/tm/tmx2source
                    for prj_path in $(find $ms_base_zzz_prjs -name "*$pisa_lang*" -type d)
                    do
                        p=$(basename "$prj_path")
                        output+=("$now: ☆ Added base TMs from $p and second source")
                        # PISA2022MS_CodingGuide_MAT-New_esp-ZZZ_en_OMT-omegat.tmx
                        short_name="${p/CodingGuide/CG}"
                        short_name="${short_name/_en_OMT.tmx/.tmx}"
                        short_name="${short_name/_OMT.tmx/.tmx}"
                        cp $prj_path/$p-omegat.tmx $ms_national_prjs/$ms_national_prj/tm/$short_name.tmx
                        cp $prj_path/$p-omegat.tmx $ms_national_prjs/$ms_national_prj/tm/tmx2source/${omt_lang^^}-MS.tmx
                    done              

                    # copy the -omegat.tmx master TM from the COG national project folder to /tm/ in the MS national project 
                    # and rename it as PISA2022MS_COG_xxx-XXX.tmx
                    for prj_path in $(find $cog_national_prjs -name "*$pisa_code*" -type d)
                    do
                        p=$(basename "$prj_path")
                        output+=("$now: ☆ Added COG national TM from $p")
                        # PISA2022MS_CodingGuide_MAT-New_esp-ZZZ_en_OMT-omegat.tmx
                        short_name="${p/_OMT_/_COG_}"
                        short_name="${short_name/_en_OMT.tmx/.tmx}"
                        short_name="${short_name/_OMT.tmx/.tmx}"
                        short_name="${short_name/MATNew/MAT-New}"
                        cp $prj_path/$p-omegat.tmx $ms_national_prjs/$ms_national_prj/tm/$short_name.tmx
                    done                          

                    # /tm       ESP/ZHO base TM                 02_${pisa_lang}-ZZZ_CG-MS    PISA2022MS_CG_*_xxx-ZZZ.tmx
                    # /tm       COG TM                          01_${pisa_code}_COG-MS  PISA2022MS_COG_*_xxx-XXX.tmx
                    # /tm/auto  National FT TM # priority 1     03_${pisa_code}_CG-FT   PISA2021FT_CG_*_xxx-XXX.tmx

                    cd $ms_national_prjs/$ms_national_prj
                    zip -r -qq $ms_national_pkgs/${ms_national_prj}.omt *
                    cd ..
                    rm -r $ms_national_prjs/$ms_national_prj
                    output+=("$now: ✔️ Done, package ${ms_national_prj}.omt created ☆☆☆")

                else
                    output+=("$now: ⚠️ Project package $ms_national_prj already exists, nothing to do")
                fi

            else
                output+=("$now: ❌ There are several base projects for $pisa_lang, only one is expected")
            fi
        else
            output+=("$now: ❌ No base project found for ${pisa_lang}-ZZZ, nothing to do for this version.")
        fi
    done
fi

output+=("==========================================================")

# write log
today=$(date +"%Y-%m-%d") # %m-%d
if test ! -e $tech_folder/log; then mkdir -p $tech_folder/log; fi
log_file="$tech_folder/log/log_${today}.txt"
touch $log_file

for i in ${output[@]}; do 
	#echo $i >> log_file
    write_to_file "$i" "$log_file"
done

# create log copy for PMs
if test ! -f $work_folder/log.txt; then rm $work_folder/log.txt; fi
ln -s $log_file $work_folder/log.txt



# restore IFS
IFS="$OIFS"

# stop process
echo "Delete this file to run the process" > $work_folder/stopped.status