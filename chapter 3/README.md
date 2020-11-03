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


### Partial Configuration
Having a backend to store the state of terraform is great. However, there is problem with using terraform backend.
Terraform backend does not support variable. Therefore, you are not allowed to change the values dynamically. Which
will cause a lot of manually copy paste work. Copy paste work generally means error prone. Current solution for this
is to extract common part of terraform backend then put inside a separate file. For example, we can extract all parts
of backend except the `key` variable to another file called `backend.hcl`. So when we want to deploy this terraform file
we have to incorporate the backend.hcl file
```bash
# move to chapter 2
terraform init -backend-config=backend.hcl
```

### Using folder layout separation
In a real project, we normally have multiple environments. For example, dev, stage and prod environment. How to build
these environments without mess each other is essential for the stability of your data center. In terraform, there are
two ways. One is using `workspace`. Which you can run command
```bash
terraform workspace list
```
to show the different workspace there. You can also create a new workspace as well
```bash
terraform workspace new WORKSPACE_NAME
```
Therefore, you can create different workspace for different envs. There is a downside by using this strategy. It's although you
are able to change different workspaces. The code you are working on not really showing you any changes or indicator which showing
you are modifying which environment. This downside is really a dangerous of setting up your infra. You may easy messy up your production
environment. Hence we have another strategy which is using folder isoltion.

Folder isolation means structure your folder into different environments. Whenever, you want to modify or deploy certain environment
you have to navigate to that specific folder first to play it. Hence by using this method you will exactly know which environment
you are currently running.