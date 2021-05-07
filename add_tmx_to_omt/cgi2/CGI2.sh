#!/bin/bash

#script to take TM's from the PISA21 Cognitive projects and put them in a coding guide project
#compile with shc -r -f CGI2.sh


#Set a few variables...
#Working directory
wdir=$(pwd)

#Here we make the user select which language they want to work on and the domain
echo "Hello!"
echo "Please type the language code for the project you want to create the coding guide package:"
read locale

#Setting up the CGfolder for the selected locale
cgdir=$"$wdir/$locale/4_CODING_GUIDES"

#Check if locale exists

if [ -d "$cgdir" ]
then
echo "Directory $cgdir exists"


else
echo "Directory $cgdir does not exist for the locale inputed"
echo "The script will now exit"
exit
fi


#echo "$locale"
echo "_____________________________________________"
echo "Now select type which domain (number):"
echo "1. Financial Litteracy"
echo "2. Creative Thinking"
echo "3. New Math"
echo "4. Reading Trend."
echo "5. Math Trend"
echo "6. Science Trend"
echo "7. Orientation"
echo "_____________________________________________"
echo "8. Merging Trend as New"
read domain
echo "_____________________________________________"

#echo "$domain"

#We select the full correct path for each domain (locale/domain/)
#We set it as initial path because we'll need a full path later on (difference between 08 and 07)
#And along with this we set the path for the CG that will need to be updated

if [ $domain = 1 ]
then
ipath=$"$locale/1_COG_FIN_LIT"
cg=$(ls $cgdir/00_FROM_ETS/*FNL*.omt)

elif [ $domain = 2 ]
then
ipath=$"$locale/1_COG_NEW_CT"
cg=$(ls $cgdir/00_FROM_ETS/*CRT*.omt)

elif [ $domain = 3 ]
then
ipath=$"$locale/1_COG_NEW_MAT"
cg=$(ls $cgdir/00_FROM_ETS/*MAT-New*.omt)

elif [ $domain = 4 ]
then
ipath=$"$locale/2_COG_TREND_REA"
cg=$(ls $cgdir/00_FROM_ETS/*REA*.omt)

elif [ $domain = 5 ]
then
ipath=$"$locale/2_COG_TREND_MAT"
cg=$(ls $cgdir/00_FROM_ETS/*MAT-Trend*.omt)

elif [ $domain = 6 ]
then
ipath=$"$locale/2_COG_TREND_SCI"
cg=$(ls $cgdir/00_FROM_ETS/*SCI-Trend*.omt)

elif [ $domain = 7 ]
then
ipath=$"$locale/1_COG_NEW_x_ORIENTATION"

elif [ $domain = 8 ]
then
bash CGI2T.sh $wdir $locale $cgdir
exit


else
echo "Please select a valid domain"
echo "The script will quit"
exit

fi

#check if the initial coding guide is present and if not kill the script

if [ -f "$cg" ]
then

echo "$cg Exists"
echo "_____________________________________________"

else

echo "_____________________________________________"
echo "No coding guide for the selected domain found in $cgdir/00_FROM_ETS"
echo "The script will now exit"
echo "_____________________________________________"
exit

fi

#Now check if there are omt files in 08

#echo "$ipath"

check08="$(find $ipath/08_FINALCHECK_reviewed_delivered/ -type f -name "*.omt" | wc -l)"
#echo "$check08"
#Now set the path to the correct folder

if [ "$check08" = 0 ]
then
path=$"$ipath/07_FINALCHECK_from_verifier"

else
path=$"$ipath/08_FINALCHECK_reviewed_delivered"
fi

#cd to the folder
cd $path

#Checks for duplicate file names and kill the script if this is the case
#from https://stackoverflow.com/a/16393181

duplicate=$(find -name "*.omt"|awk -F"/" '{a[$NF]++}END{for(i in a)if(a[i]>1)print i,a[i]}')

if [ -z "$duplicate" ]
then
echo "No duplicate packages"
echo "_____________________________________________"

else

echo "Duplicate packages detected!"
echo "The script will now quit"
echo "Error log:"
echo "Path to folder: $path"
echo "_____________________________________________"
echo "Duplicated file(s) name: $duplicate"
echo "_____________________________________________"
find -type f -name "*.omt" 
echo "_____________________________________________"
exit

fi
pwd
#Now copy the packages to the same location
mkdir omt
echo "Copy all packages to a single location"
echo "_____________________________________________"

#First remove spaces for dirnames and filenames

find -name "* *" -type d | rename 's/ /_/g'
find -name "* *" -type f | rename 's/ /_/g'

for omtfile in $(find -name "*.omt")
do
cp -v "$omtfile" omt/
done

#compile the omt projects
echo "Compiling the OmegaT projects"
cd omt/
#check if folder contains omt
count=$(ls -1 *.omt 2>/dev/null | wc -l)
if [ $count != 0 ]
then 

#then convert them to zip...
for f in *.omt
do 
    mv -- "$f" "${f%.omt}.zip"
done

#...and extract them
for zip in $(ls *.zip) 
do

name=$(echo "$zip" | cut -f 1 -d '.')
unzip "$zip" -d "$name"
rm $zip
done

else

echo "No omt files detected"
exit

fi  

#Now make the final TM's for the projects, storing them in a TM folder

mkdir ../TM/
for folder in $(ls)
do

#clean any TMX that might already exist in the omt packages
rm $folder/*.tmx

#compile OmegaT projects, updating the TM's in the meantime
/opt/omegat/OmegaT-default/jre/bin/java -jar /opt/omegat/OmegaT-default/OmegaT.jar $folder --config-dir=/home/ad/.capstan/config/ --config-file=/home/ad/.capstan/config/omegat.prefs --mode=console-translate --quiet >> /dev/null
cp -v "$folder"/*level1.tmx ../TM/
echo "Done compiling $folder"

done

#Clean the TMX of the tags they might contain (should not but why not?)

cd ../TM/

echo "Cleaning TMX files"
echo "_____________________________________________"

for tmx in $(ls *.tmx)
do

perl -pi -e 's/&lt;[^&;]+&gt;//g' $tmx

done

#Do some preparation for the TMX transfer (copy omt to 02, copy the TM's there)

echo "Here!"
echo "$PWD"
#Copy the TM's
mkdir -p $cgdir/00_TO_COUNTRY/tmp/TM/
cp *.tmx $cgdir/00_TO_COUNTRY/tmp/TM/
#Clean the files here
cd ../
rm -r omt TM


#Copy the omt packages
echo "CG is $cg"

cd $cgdir/00_FROM_ETS/
cp "$cg" ../00_TO_COUNTRY/tmp/


#Extract CG omt packages
cd ../00_TO_COUNTRY/tmp/

for f in $(ls *.omt)
do 
    mv -- "$f" "${f%.omt}.zip"
done

#...and extract them
for zip in $(ls *.zip) 
do

name=$(echo "$zip" | cut -f 1 -d '.')
unzip "$zip" -d "$name"
rm $zip
CG_proj=$(echo $name)
done


#Do some cleaning on the CG projects + create tm/auto/COG + copy the TM's

for proj in $(ls -d PISA*)
do
rm $proj/*.tmx
#rm $proj/omegat/*.tmx
mkdir -p $proj/tm/enforce/COG
cp -v TM/* $proj/tm/enforce/COG
tmcontent=$(ls -1 $proj/tm/enforce/*)
java -cp /opt/omegat/OmegaT-default/OmegaT.jar:/home/ad/.capstan/config/plugins/plugin-omt-package-1.1.0.jar net.briac.omegat.plugin.omt.ManageOMTPackage $proj $proj.omt
rm -r $proj
mv -v $proj.omt ../
done

#Doing some clean-up
cd ../
#rm -r tmp/

echo "_____________________________________________"
echo "Packages succesfuly created in $PWD!"
echo "_____________________________________________"
echo "The following TM's were added to the project:"
echo "$tmcontent"
echo "_____________________________________________"


