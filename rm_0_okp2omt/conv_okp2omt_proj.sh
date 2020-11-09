#!/bin/bash

# cd to omegat project folder
# bash this_script


# if this is an English version
if [[ $proj_qq_pkg == *"_eng-"* ]]; then
  unzip -d $proj_qq_dir $proj_qq_pkg
  cd $proj_qq_dir
  # backup internal file separators and keep only linebreaks
  OIFS="$IFS" && IFS=$'\n'
  # remove the appended _0 from IDs
  perl -i -pe 's~(<prop type="id">.+)_0(</prop>)~$1$2~g' $(find ./tm -type f)
  perl -i -pe 's~(<prop type="id">.+)_0(</prop>)~$1$2~g' $(find ./omegat -type f)
  perl -i -pe 's~(tuid=".+)_0(">)~$1$2~g' $(find ./tm -type f)
  # restore internal file separators
  IFS="$OIFS"
  # enable default XLIFF filter
  perl -i -pe 's/(?<=org.omegat.filters3.xml.xliff.XLIFFFilter" enabled=")false/true/' omegat/filters.xml
  # delete initial project
  rm -r ../$proj_qq_pkg
  # pack project again
  zip -r ../$proj_qq_pkg *
  cd ..
fi
