#!/bin/bash

set -e

if [ $# -ne 1 ] ; then
    echo "Usage: $0 BRANCH"
    exit 2
fi
# Check that the branch name is HOPS-[0-9]+    

SCRIPTNAME=`basename $0`
SCRIPTDIR=`dirname $0`
BASEDIR=`dirname $SCRIPTDIR`
COOKBOOK=""
REPO=""
BRANCH=$1

checkout()
{
    pushd .
    cd ../$REPO
    git pull origin master
    git checkout -b $BRANCH
    git push -u origin $BRANCH    
    popd
    echo "$REPO" >> .${BRANCH}    
}

clear_screen()
{
 echo "" 
 echo "Press ENTER to continue"
 read cont < /dev/tty
 clear
}

clone()
{
  echo ""    
  echo "Could not find $COOKBOOK in the directory  $BASEDIR "
  echo "" 
  printf "Do you want to clone $COOKBOOK into the directory $BASEDIR ? [ yes or no ] "
  read ACCEPT
  case $ACCEPT in
    yes | Yes | YES)
      ;;
    no | No | NO)
	echo "Exiting..."
	echo ""
      exit 2
      ;;
    *)
      echo "" 
      printf "Please enter either 'yes' or 'no'." 
      clone
    ;;
  esac
  #  clear_screen

  pushd .
  cd ..
  git clone git@github.com:hopshadoop/${REPO}.git
  cd $REPO
  git pull origin master
  popd
}

FINISHED=0

echo "" > .${BRANCH}

while [ $FINISHED -eq 0 ]; do

    echo "0  FINISHED"
    echo "1  conda"
    echo "2  kagent"
    echo "3  hops"
    echo "4  ndb"
    echo "5  hadoop_spark"
    echo "6  flink"
    echo "7  zeppelin"
    echo "8  livy"
    echo "9  drelephant"
    echo "10 tensorflow"
    echo "11 epipe"
    echo "12 dela"
    echo "13 kzookeeper"
    echo "14 kkafka"
    echo "15 elastic"
    echo "16 hopslog"
    echo "17 hopsmonitor"
    echo "18 hive"

    printf 'Enter the number of the subproject (COOKBOOK) you wish to checkout ('0' to finish): '
    COOKBOOK=""
    REPO=""

    read ACCEPT
    case $ACCEPT in
	0 | "finish")
	    FINISHED=1
	    ;;
	1 | conda)
	    COOKBOOK="conda"
	    REPO="conda-chef"    
	    ;;
	2 | kagent)
	    COOKBOOK="kagent"
	    REPO="kagent-chef"    
	    ;;
	3 | hops)
	    COOKBOOK="hops"
	    REPO="hops-hadoop-chef"    
	    ;;
	4 | ndb)
	    COOKBOOK="ndb"
	    REPO="ndb-chef"    
	    ;;
	5 |  hadoop_spark)
	    COOKBOOK="hadoop_spark"
	    REPO="spark-chef"    
	    ;;
	6 | flink)
	    COOKBOOK="flink"
	    REPO="flink-chef"    
	    ;;
	7 | zeppelin)
	    COOKBOOK="zeppelin"
	    REPO="zeppelin-chef"    
	    ;;
	8 | livy)
	    COOKBOOK="livy"
	    REPO="livy-chef"    
	    ;;
	9 | drelephant)
	    COOKBOOK="drelephant"
	    REPO="drelephant-chef"    
	    ;;
	10| tensorflow)
	    COOKBOOK="tensorflow"
	    REPO="tensorflow-chef"    
	    ;;
	11| epipe)
	    COOKBOOK="epipe"
	    REPO="epipe-chef"    
	    ;;
	12| dela)
	    COOKBOOK="dela"
	    REPO="dela-chef"    
	    ;;
	13| kzookeeper)
	    COOKBOOK="kzookeeper"
	    REPO="kzookeeper"    
	    ;;
	14| kkafka)
	    COOKBOOK="kkafka"
	    REPO="kafka-chef"    
	    ;;
	15| elastic)
	    COOKBOOK="elastic"
	    REPO="elastic-chef"    
	    ;;
	16| hopslog)
	    COOKBOOK="hopslog"
	    REPO="hopslog-chef"    
	    ;;
	17| hopsmonitor)
	    COOKBOOK="hopsmonitor"
	    REPO="hopsmonitor-chef"    
	    ;;
	18| hive)
	    COOKBOOK="hive2"
	    REPO="hive-chef"    
	    ;;
	*)
	    echo ""
	    echo "Invalid choice. Enter the name or number of the COOKBOOK."
	    ;;
    esac

    if [ "$REPO" != "" ] ; then
      echo "Cookbook chosen: $COOKBOOK"
	
      echo ""
      if [ ! -d ../$COOKBOOK ] ; then
 	clone
      fi
      checkout
    fi

done

REPO="hopsworks-chef"
COOKBOOK="hopsworks"
checkout
