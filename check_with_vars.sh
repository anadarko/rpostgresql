#!/bin/bash

## either define the variables here (and get a diff to SVN)
##
## export POSTGRES_USER="someuser"
## export POSTGRES_PASSWD="..."
## export POSTGRES_HOST="somehost"
## export POSTGRES_DATABASE="testing124"
## export POSTGRES_PORT="5432"
##
## or write them to a local file that can get sourced here
##
if [ -f ~/.RPostgreSQL_Test_Vars ]
then
    . ~/.RPostgreSQL_Test_Vars
fi

echo " "
echo "-------------- write version info ----------------------"

tempfile=`mktemp Rpostgresql.txt.XXXXXXXX`

if [ -x sw_vers ]
then
	sw_vers
elif [ -x lsb_release ]
then
	lsb_release -a
fi

svn_version=$(svnversion -n)
echo "RPostgreSQL svn version: $svn_version"
psql --version | head -n 1

#R --version | head -n 1

R --slave -e 'sessionInfo(); capabilities()' >$tempfile
echo " "
head -n 5 $tempfile

R --slave -e 'packageDescription("RPostgreSQL", fields = c("Package", "Version", "Packaged", "Built"))' >$tempfile
echo " "
head -n 4 $tempfile

rm $tempfile

#R CMD check RPostgreSQL

for f in RPostgreSQL/tests/*.R
do
    echo "==== Running $f"
    R --slave < $f
done

echo "Done"
exit 0
