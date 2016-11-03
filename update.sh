#!/bin/bash

set -e

dir='json'
backupDir='backup'

targetId=$1

if [ -z "$targetId" ]; then
	echo "Usage:" 1>&2
	echo '  ./update.sh ${targetId}' 1>&2
	exit 1
fi

jsonPath="$dir/$targetId.json"

if [ ! -e $jsonPath ]; then
	echo "json file not found [$jsonPath]"
	exit 1
fi

lastModifiedTime=`cat $jsonPath | jq -r '.Distribution.LastModifiedTime'`

mkdir -p $backupDir
cp $jsonPath "$backupDir/${targetId}_${lastModifiedTime}"

dstJson=`cat $jsonPath | jq -r '{ DistributionConfig: .Distribution.DistributionConfig, Id: .Distribution.Id, IfMatch: .ETag }'`

dst=`aws cloudfront update-distribution --cli-input-json "$dstJson"`

echo $dst | jq '.' > $jsonPath
