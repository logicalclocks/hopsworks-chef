#!/bin/bash

set -e
echo "gathering external params for metadata.rb"

rm -f params.txt
touch params.txt

for i in kagent-chef ndb-chef hops-hadoop-chef spark-chef flink-chef epipe-chef livy-chef kzookeeper kafka-cookbook elasticsearch-chef dr-elephant-chef zeppelin-chef dela-chef 
do
   string="$(cat ../${i}/metadata.rb)"
   result="${string#"${string%%attribute*}"}"
   echo "$result" >> params.txt 
#2>&1 > /dev/null
done

./meta.sh
mv metadata.rb.new metadata.rb

#echo 'To recover original metadata.rb, use'
#echo 'perl -pi -e "s/(### BEGIN GENERATED CONTENT\n).*?/$1/s" metadata.rb'
rm params.txt
#perl -0777 -i -pe "s/(### BEGIN GENERATED CONTENT\\n).*(\\n### END GENERATED CONTENT)/$1$newContent$2/s" metadata.rb

echo "metadata.rb updated with parameters from dependent hops cookbooks"
echo ""
