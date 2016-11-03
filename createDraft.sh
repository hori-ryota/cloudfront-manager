#!/bin/bash

set -e

dir='json'
draftDir='draft'

mkdir -p $draftDir

targetName=$1
sourceId=$2

if [ -z "$targetName" ]; then
	echo "Usage:" 1>&2
	echo '  ./createDraft.sh ${targetName} [${sourceId}]' 1>&2
	exit 1
fi

jsonPath="$draftDir/$targetName.json"

if [ -e $jsonPath ]; then
	echo "json file exists [$jsonPath]"
	exit 1
fi

if [ -z "$sourceId" ]; then
  aws cloudfront create-distribution --generate-cli-skeleton > $jsonPath
  echo "create $jsonPath success!"
	exit 0
fi

sourceJsonPath="$dir/$sourceId.json"

if [ ! -e $sourceJsonPath ]; then
	echo "source json file not found [$sourceJsonPath]"
	exit 1
fi

callerReference="`date +%s`000"
echo $callerReference

cat $sourceJsonPath | jq -r ".Distribution
| { DistributionConfig: .DistributionConfig }
| .DistributionConfig.CallerReference = \"${callerReference}\"" > $jsonPath

echo "$jsonPath created"
