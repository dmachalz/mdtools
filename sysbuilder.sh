#! /bin/bash
CWD=`/usr/bin/pwd`
echo "Usage: bash /mdspace/davidm/tools/mdtools/sysbuilder.sh <MAE file 1> ... <MAE file 2>"

# Setting up environment, etc.
export SCHRODINGER='/software/desmond/2018-3'
#Path to the used template method file
templateMSJ='/mdspace/davidm/cyp4z1/inhib/md-prep/sysbuilder.msj'


# System building..
LIST="$@"
for FILE in $LIST; do
	INFILE=$( basename $( echo $FILE ) )
	systemname=$( echo $INFILE | sed "s#.mae##")
	WORKDIR=$( realpath $( dirname $( echo $FILE ) ) )
	OUTFOLDER=$( echo $systemname)
	if [ -f "$FILE" ] && [ ! -z $systemname ]; then
		cd $WORKDIR
		mkdir $OUTFOLDER
		cd $OUTFOLDER
		#start system builder with MAE and MSJ
		echo "Running system builder for $FILE"
		echo
		"${SCHRODINGER}/utilities/multisim" -JOBNAME $systemname -m $templateMSJ ${WORKDIR}/${INFILE} -o ${systemname}-out.cms -maxjob 1 -HOST localhost -TMPLAUNCHDIR -ATTACHED
		# removing useless backup data of individual stages
  else
		echo "Cannot find MAESTRO file"
	fi
  cd $CWD
done
