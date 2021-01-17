# SWZ News Terraform Administrative account

The goal of this configuration directory is to provide the initial setup on AWS/Github with the following resources:

* Github repository
* S3 buckets to store Terraform state files
* DynamoDb Lock tables to lock Terraform state
* Code pipeline webhook
* CodePipeline and CodeBuild for Terraform configuring child account

## Chicken or the egg dilemma

It's common to store Terraform state in a backend service. 
If an existing backend service like Terraform Cloud or Consul is not available, it's common to create a backend service in a 
cloud provider to store the state, and it's also common to use Terraform to create this service.

For this reason, this Terraform configuration needs some environment variables in order to run for the first time. 
These variables will be stored on AWS SSM and it will be able to deploy its own CodePipeline with those variables populated. 
