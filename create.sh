#!/bin/bash

set -e

dir='json'
draftDir='draft'

targetName=$1

if [ -z "$targetName" ]; then
	echo "Usage:" 1>&2
	echo '  ./create.sh ${targetName}' 1>&2
	exit 1
fi

jsonPath="$draftDir/$targetName.json"

if [ ! -e $jsonPath ]; then
	echo "json file not found [$jsonPath]"
	exit 1
fi

srcJson=`cat $jsonPath`

dst=`aws cloudfront create-distribution --cli-input-json "$srcJson"`

id=`echo $dst | jq -r '.Distribution.Id'`

mkdir -p $dir
echo $dst | jq 'del(.Location)' > "$dir/$id.json"
