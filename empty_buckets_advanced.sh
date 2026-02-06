#!/bin/bash
set -e

buckets=(
    "myapp-staging-artifacts-332809474715"
    "myapp-staging-pipeline-332809474715"
)

for bucket in "${buckets[@]}"; do
    echo "Processing bucket: $bucket"
    
    # 1. Delete Versions
    echo "Listing versions..."
    versions=$(aws s3api list-object-versions --bucket "$bucket" --output json --query 'Versions[].{Key:Key,VersionId:VersionId}')
    
    if [ "$versions" != "null" ] && [ "$versions" != "[]" ]; then
        echo "Deleting versions..."
        aws s3api delete-objects --bucket "$bucket" --delete "{\"Objects\": $versions, \"Quiet\": true}"
    else
        echo "No versions found."
    fi

    # 2. Delete DeleteMarkers
    echo "Listing delete markers..."
    markers=$(aws s3api list-object-versions --bucket "$bucket" --output json --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}')
    
    if [ "$markers" != "null" ] && [ "$markers" != "[]" ]; then
        echo "Deleting markers..."
        aws s3api delete-objects --bucket "$bucket" --delete "{\"Objects\": $markers, \"Quiet\": true}"
    else
        echo "No delete markers found."
    fi
done

echo "Buckets emptied."
