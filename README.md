# Snyk AWS Deploy

This is a terraform project to deploy aws resources to run Snyk Sync.

Limitations:

- Assumes you have permissions create a vpc, secret, ande deploy secrets to secret manager
- IAM roles need tuning to restrict access to keys

To get started, create a terraform.tfvars file similar to the one below.

The values for "team and creator" are used to create tags on the resources.

"source_subnet" Is used for the SSH Ingress rule, use 0.0.0.0/0 for everyone (which is not reccomended)

The AMI used is the latest Amazon Linux 2 instance, but any CentOS/RedHat instance with python 3.7 or later installed along with the aws cli tools should work.

```
region        = "eu-west-1"
team          = "cse"
creator       = "chris"
ami           = "ami-00ae935ce6c2aa534"
instance_type = "t2.micro"
namespace     = "snyk-sync"
source_subnet = "23.3.234.234/32"
key_name      = "cbarker"
secrets = {
  "SNYK_TOKEN_cse_group" = "77071601-1BCD-4353-8523-331A59FD1E5A",
  "GITHUB_TOKEN"         = "ghp_EAFD53BA-5402-4187-A742-730B365E6D3D"
  "SYNC_CONFIG_REPO"     = "https://github.com/snyk-playground/sync-config.git"
}
```

## Changes to EC2 Instance

Once launched, the [user_data.sh](used_data.sh) script will prep the instance by installing git, poetry, jq and updating python. It creates a bin directory with a git-credential helper that exposes the github_token in the ENV to the git client for retrieving both the snyk-sync project itself and the repo containing the configuration file.

After creating the virtual environment for snyk sync and installing dependencies, the script will copy the latest version of the [aws_cron.sh](https://github.com/snyk-playground/snyk-sync/blob/main/scripts/aws_cron.sh) script from the snyk-sync repo. This script lives in `~ec-user/bin` and is the default target for a cronjob meant to run snyk-sync nightly, performing all the needed imports.

If you deploy a cron.sh script to you repository you're using for configuration, the aws_cron.sh will instead run that script.

The cron settings themselves are copied from crontab-entry used in the configuration source.

Once Terraform has completed the installation, you will need to connect to the instance once and run `bash bin/aws_cron.sh` to verify that it was able to deploy the proper tools into the EC2 instance, the secrets were populated correctly, and an import was successfully run. Executing the aws_cron.sh script will install the cron job for you.

## Example configuration repository

See the [example repo](https://github.com/snyk-playground/sync-config) used by the snyk-sync test environment

## Logging

Logging / storage is a still a work in progress, but attaching an S3 bucket and scheduling uploads of the import logs daily contents to bucket is planned in a future version.
