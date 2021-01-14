#! /bin/bash


### CONFIG start ###
TEMPFOLDER='/mdspace/tmp';
### CONFIG end ###

# List version of mdmonitor, which considers jobid to exclude duplicates.
# author David Machalz
# version history /change log
version='0.12'
# version 0.11: implemented HOST # changed double to single space between columns # changed formatting width for columns, increased jobname column width to 16
# version 0.12: Changed from looping over log files to jobids to remove duplicates. Now jobnames do not have to be unique since the jobid is used for handling. Added statement, if no jobs are running.

# switch to print the list legend by default
printlegend=0

# Looking for all logfiles and jobids in the temp folder
alllogslist=$( find "$TEMPFOLDER" -mindepth 2 -maxdepth 3 ! -readable -prune -o -ctime -1 -name "*.log" -and ! -name "*multisim.log" | sort )
jobidlist=$(
  for f in $( find "$TEMPFOLDER" -mindepth 2 -maxdepth 3 ! -readable -prune -o -ctime -1 -name "*.log" -and ! -name "*multisim.log" ); do
    jobid=$( grep -E "JobId: " $f 2>/dev/null | awk -F 'JobId: ' '{ print $2}' );
    if [ "$jobid" != '' ]; then
      echo $jobid;
    fi;
  done)

if [ "$jobidlist" != '' ]; then
  # Providing table header
  echo \
  "U          J                HT   ST     TT   PR   SS    ET"

  # Iterating over list of unique jobIDs.
  for jobid in $( echo $jobidlist | tr ' ' '\n' | sort | uniq ); do
    # Creating bash array of valid logfiles containing jobID
    loglist=();
    for l in $( echo $alllogslist ); do
      if [ "$( grep $jobid $l 2>/dev/null )" != '' ]; then
        loglist+=( $l );
      fi;
    done;
    logfile=${loglist[-1]}
    f=$( dirname $logfile )
    jobfile=$( find "$( dirname $logfile )" -name "$jobid" )
    # Gathering info from log file
    username=$( grep "user: " $logfile | awk -F ':' '{print $3}' )
    jobname=$( basename $logfile | awk -F '.log' '{ print $1 }')
    host=$( grep -E "host[0-9]:" $logfile | awk -F': ' '{ print $NF }' )
    maxtimeNS=$( echo "scale=2; $( grep '    time = \"' $logfile | tail -n 1 | awk -F'\"' '{ print $2 }' ) /1000" | bc -l 2>/dev/null);
    simtimePS=$( tail -n 1 $logfile | awk '{ print $3 }' | awk -F'.' '{ print $1 }' );
    simtimeNS=$( echo "scale=2; $simtimePS/1000" | bc -l 2>/dev/null);
    percent=$( echo "scale=2; $simtimeNS * 100 / $maxtimeNS" | bc -l 2>/dev/null)
    speed=$( tail -n 1 $logfile | awk '{ print $8 }' )
    speedlist=$( tail -n 10 $logfile | awk '{ print $8 }' )

    # Calculating the average simulation speed based on the last 10 entries
    c=0;
    for i in $speedlist; do
      c=$( echo "$c+$i" | bc 2>/dev/null); # Calculating the sum of speedlist
    done;
    c=$( echo "scale=3; $c/10" | bc 2>/dev/null)  # Calculating the mean form sum
    speedmean=$( echo "$c" )

    # Estimating runtime of MD simulation in days and hours
    esttimeDAYS=$( echo "scale=2; ($maxtimeNS - $simtimeNS) / $speedmean" | bc -l 2>/dev/null)
    esttimeHOURS=$( echo "scale=2; 24* ($maxtimeNS - $simtimeNS) / $speedmean" | bc -l 2>/dev/null)

    # Formatted output
    printf "%10.10s %16.16s %4.4s %5.1f/%5.0f %4.1f %5.1f %5.1f\n" $username $jobname $host $simtimeNS $maxtimeNS $percent $speedmean $esttimeHOURS
    # Making sure the legend is appended to the list output
    printlegend=1
  done
else
  echo "No MD jobs running at the moment."
fi

# Legend printing
if [ "$printlegend" == "1" ]; then
  echo \
"
U: user  J: jobname  HT: host  ST: simulation time done [ns]
TT: simulation time total [ns]  PR: Progress [%]
SS: simulation speed [ns/24h] with (n=10)
ET: Estimated remaining time [h]               version: $version
"
fi
