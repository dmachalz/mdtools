#! /bin/bash
# This script allow the generation of input files for DESMOND MDs
# Setting up environment, etc.
CWD=`/usr/bin/pwd`
echo "Usage: bash /mdspace/davidm/tools/mdtools/confgen.sh <CMS file> <CFG file template>"
echo "The order of the CMS/CFG files is important!"

templateMSJ='/mdspace/davidm/tools/mdtools/confgen-template.msj'
CMSOLDSUFFIX="-out.cms"

FILE=$1
templateCFG=$2


if [ $# -eq 2 ]; then
  systemname=$( basename $FILE | sed "s#$CMSOLDSUFFIX##g")
  WORKDIR=$( realpath $( dirname $( echo $FILE ) ) )
  CMS=${systemname}.cms
  MSJ=${systemname}.msj
  CFG=${systemname}.cfg
  echo "Preparing files for $systemname"
  if [ -f "$FILE" ] && [ ! -z $systemname ] && [ -f "$templateCFG" ]; then
    mv $( realpath $FILE ) ${WORKDIR}/$CMS
    cp $templateMSJ ${WORKDIR}/$MSJ
    cp $templateCFG ${WORKDIR}/$CFG
    # Replacing the CFG file name in the method file
    sed -i "s#REPLACEMEPLEASE1#$CFG#" ${WORKDIR}/$MSJ
  else
    echo "Please check CMS and CFG file."
  fi

else
   echo "Please provide CMS and CFG file."
fi

echo "Done."
cd $CWD
