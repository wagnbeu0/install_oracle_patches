#/bin/bash
# Script for automatic insallation of Oracle Critical Patch updates CPU
# Version 1.0 - 31.07.2014

shutdown_oracle ()
{
	echo Oracle database instance name is $i
	export ORAENV_ASK=NO
	export ORACLE_SID=$1
	sqlplus / as sysdba <<-EOF
	shutdown immediate;
	exit;
	EOF
}

startup_oracle_19c ()
{
	export ORAENV_ASK=NO
	export ORACLE_SID=$1
	sqlplus / as sysdba <<-EOF
	startup;
	quit;
	EOF

	cd $ORACLE_HOME/OPatch/
	./datapatch -verbose
}

echo Script for automatic patch of Oracle

export SCRIPT_ROOT=`pwd`
export ORACLE_HOME=`cat /etc/oratab | grep product | grep 19 | cut -d: -f 2| uniq`
export ORACLE_BASE=/oracle
export PATH=$PATH:$ORACLE_HOME/bin/
export PATH=$PATH:$ORACLE_HOME/OPatch
export PATCH=$1
export PATCH_FOLDER=`echo $PATCH | cut -f1 -d_ | cut -c2-`
export ROOT_FOLDER=$SCRIPT_ROOT/$PATCH_FOLDER
export OPATCH_FILE=p6880880_190000_Linux-x86-64.zip

if [ ! -d $ORACLE_HOME ]
    then
        echo ================================================================
        echo Sorry: ORACLE_HOME $ORACLE_HOME does not exist. 
        echo Please enter the correct value and try again!
        exit 0
        echo ================================================================
fi

if [ "$1" = "" ]
then
	echo ================================================================
	echo Wrong syntax:
	echo Please apply the name of the Patch file:
	echo
	echo ./install_CPU.sh p\<Oracle Patch number\>.zip
	echo
	echo ================================================================
	exit 0
fi

if [ ! -f $1 ];
	then
		echo ================================================================
		echo The Patch $1 does not exist in the current directory.
		echo Please copy it to this folder and run again.
		echo ================================================================
		exit 0
fi

if [ ! -f $OPATCH_FILE ];
	then
			echo ================================================================
		echo The OPATCH $OPATCH_FILE does not exist in the current directory.
		echo Please copy it to this folder and run again
		echo ================================================================
		exit 0
fi

echo Patch OPatch to latest version
rm -rf $ORACLE_HOME/OPatch*
unzip -o $OPATCH_FILE -d $ORACLE_HOME
if [ $? != 1 ]
 then 	
	echo Successful: OPATCH is now the latest version ...
else
	echo ERROR: OPATCH could not be upgraded, please check manually ...
	break
fi

unzip -o $PATCH
cd $PATCH_FOLDER
export PATCH_FOLDER=`pwd`
echo Current Patch folder is $ROOT_FOLDER
opatch prereq CheckConflictAgainstOHWithDetail -ph ./

echo Stop all running Oracle processes
for i in `cat /etc/oratab | grep :/ | cut -f1 -d:`
do
	shutdown_oracle $i
done
$ORACLE_HOME/bin/lsnrctl stop

echo Patch the following Oracle Home:	$ORACLE_HOME
echo cd $ROOT_FOLDER
cd $ROOT_FOLDER
opatch apply -silent
if [ $? != 0 ]
 then 	
	# clear
	echo ERROR: OPATCH is not the current version, try to update ...
	echo mv $ORACLE_HOME/OPatch $ORACLE_HOME/OPatch_`date +%d.%m.%y_%T`
	mv $ORACLE_HOME/OPatch $ORACLE_HOME/OPatch_`date +%d.%m.%y_%T`
	
	
	echo unzip -o $SCRIPT_ROOT/$OPATCH_FILE
	unzip -o $SCRIPT_ROOT/$OPATCH_FILE
	echo mv ./OPatch $ORACLE_HOME/OPatch
	mv ./OPatch $ORACLE_HOME/OPatch

	
	echo opatch apply
	opatch apply -silent
	if [ $? != 0 ]; then exit 0; fi
else
	echo Patch $PATCH has been successful installed. Going on with internal database patching ...
fi

echo start all local listeners
$ORACLE_HOME/bin/lsnrctl start


echo Patch Oracle PSU Tables
for i in `cat /etc/oratab | grep :/ | grep 19 | cut -f1 -d:`
do 
		startup_oracle_19c $i
done

echo Delete Patchfolder to clean up
rm -rf $PATCH_FOLDER

echo	All local databases has been successful patched with patch $PATCH 


