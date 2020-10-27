## Terraform State

In order to make multiple developer to develop terraform code, we need a centralized the service
to store the state file. Here we choose aws s3 service. Also if multiple developers working simultaneously
we need a machanism to lock the state file in order to prevent the update at the same time. Here we
using dynamodb to achieve the lock functionality.

This code inside this folder is pretty a way to setup the terraform state store and sync. After having
this s3 storage, you are able to deploy your other infrastructure by storing the state in the s3 bucket.
Therefore, you can go to chapter 2 to add extra terraform backend block to let s3 to track the state
instead of using local tfstate file.

you can deploy the s3 and dynamodb in this folder
```bash
# you init to download the supported libs
terraform init
# you can dry run as usual
terraform plan
# deploy your s3 bucket
terraform apply -auto-approve
```
after deploied the s3 bucket, go the chapter 2 folder, deploy the code as before