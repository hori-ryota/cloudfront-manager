#!/bin/bash

set -eu

dir='json'
mkdir -p $dir

targetIds=`aws cloudfront list-distributions | jq '.DistributionList.Items | map(select(.["Enabled"] == true) | .Id)'`
echo $targetIds | jq "."

len=`echo $targetIds | jq length`

for i in `seq 0 $(($len-1))`; do
  targetId=`echo $targetIds | jq -r ".[$i]"`
  echo "fetch $targetId"
  target=`aws cloudfront get-distribution --id $targetId`
  echo $target | jq '.' > "$dir/$targetId.json"
done
