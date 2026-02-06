
import boto3

def empty_bucket(bucket_name):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    
    try:
        print(f"Emptying bucket: {bucket_name}")
        bucket.object_versions.delete()
        print(f"  Deleted all object versions in {bucket_name}")
    except Exception as e:
        print(f"  Error emptying {bucket_name}: {e}")

if __name__ == "__main__":
    buckets = [
        "myapp-staging-artifacts-332809474715",
        "myapp-staging-pipeline-332809474715"
    ]
    for b in buckets:
        empty_bucket(b)
