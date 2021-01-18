#! /bin/#!/usr/bin/env bash
# Setting up environment, etc.
export SCHRODINGER='/software/desmond/2018-3'
CWD=`/usr/bin/pwd`

# Protein h-bond optimization
LIST="$@"
for FILE in $LIST; do
  WORKDIR=$( dirname $( echo $FILE ) )
  INFILE=$( basename $( echo $FILE ) )
  # CAVE: this line will likely break with different input file name!!!
  OUTFILE=$( echo $INFILE | sed 's#preprocessed.mae#processed.mae#g' )
  JOBNAME=$( echo $INFILE | sed 's#preprocessed.mae##g' )
  if [ -f "$FILE" ] && [ ! -z $OUTFILE ]; then
    cd $WORKDIR
    echo "Running protassign for $FILE"
    $SCHRODINGER/utilities/protassign -j $JOBNAME -nowater -propka_pH 'auto' $INFILE $OUTFILE
  else
    echo "Cannot read input file $FILE. Moving to next file"
    echo "REQUIREMENT: input files need to end on 'preprocessed.mae'"
  fi
  cd $CWD
done
