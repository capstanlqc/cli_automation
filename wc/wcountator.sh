# !/usr/bin/env bash

cd $PWD

# check if folder contains omt or zip files...
count=`ls -1 *.omt *.zip 2>/dev/null | wc -l`

if [ $count != 0 ]
then
    # then convert them to zip...
    for f in *.omt
    do
        mv -- "$f" "${f%.omt}.zip"
    done

    # ...and extract them
    for zip in $(ls *.zip)
    do
        name=$(echo "$zip" | cut -f 1 -d '.')
        unzip "$zip" -d "$name"
        rm $zip
    done

else
    echo "No omt files detected"
fi

mkdir .tmp

# create project stats and put it in tmp folder
# for folder in $(ls -d -- */)
for folder in $(ls)
# for folder in $(ls -dl */)
do
    # compile OmegaT projects, updating the wordcounts in the meantime
    # /opt/omegat/OmegaT-default/jre/bin/java -jar /opt/omegat/OmegaT-default/OmegaT.jar --config-dir=/home/ad/.omegat/config/ --config-file=/home/ad/.omegat/config/omegat.prefs "$folder" --script=/home/$USER/.omegat/scripts/write_project2excel.groovy --mode=console-translate --quiet
    /opt/omegat/OmegaT-default/jre/bin/java -jar /opt/omegat/OmegaT-default/OmegaT.jar  "$folder" --mode=console-translate --script=/home/ad/.omegat/scripts/write_project2excel.groovy

    cp -v $folder/omegat/project_stats.txt .tmp/$folder.txt
done

mkdir WC/
cd .tmp/

for file in $(ls *.txt)
do
    # extract header and store
    sed -n '2,10p' "$file" > head.txt
    head=$(csvtool -t "TAB" -u ";" col "1-6" head.txt)
    
    # remove header
    rm head.txt
    sed -i '1,12d' "$file"

    # extract needed columns
    stats=$(csvtool -t "TAB" -u ";" col "1,2,6,8,10,14" "$file")

    # remove everything up to file extension
    name=$(echo "$file" | cut -f 1 -d '.')

    # make file with stored values
    echo "$head" >> ../WC/$name.csv
    echo "$stats" >> ../WC/$name.csv

    # convert csv to xls
    echo "Making file for $name"
    unoconv -f xls -i FilterOptions="59,,,1" ../WC/$name.csv
    rm ../WC/*.csv
done

cd ../
rm -r .tmp/
