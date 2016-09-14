#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "usage: $0 packer.json"
  exit 1
fi

rm -rf Berksfile.lock
rm -rf vendor
berks vendor vendor/cookbooks
PACKER_LOG=1 packer build \
  -var "account_id=$AWS_ACCOUNT_ID" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
  -var "x509_cert_path=$AWS_X509_CERT_PATH" \
  -var "x509_key_path=$AWS_X509_KEY_PATH" \
  -var "s3_bucket=hopshadoop" \
  -only=amazon-instance $1
