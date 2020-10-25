## Terraform bootcamp

This is a bootcamp for learning terraform. This bootcamp is mainly based on the book [Terraform up and running](https://www.amazon.com.au/Terraform-Up-Running-Yevgeniy-Brikman/dp/1492046906)
This book has 8 chapters. However, not all of chapters have codings. This bootcamp will only contain code for learning purpose, anyone interested in learning terraform. My suggestion is to
buy this book, it's an amazing book!

### How to navigate through code
The code in this repo is designed in an incremental way. Therefore, you have to check the tag to learn it step
by step, the tag is designed as `chapter_x-version_x`. Which means the code belongs which chapter and which version
to list all tags issue following commands
```bash
git tag -n9
```
to checkout a tag, issuing following command
```bash
# Here you have to replace TAG_NAME to an appropriate one
# change YOUR_BRANCH_NAME to your favourate one
git checkout tags/TAG_NAME -b YOUR_BRANCH_NAME
```

### Deploy the infrastructure by using terraform
Make sure you have Terraform and AWS account setup.

To dry-run the deployment, issue following code
```bash
terraform plan
```
the command above will give you overview of what resources will be deployed

To really deploy the infrastructure,
```bash
terraform apply
```
this command will ask you to confirm if you consensus the resources to deploy.

If you do not want to type yes to confirm each time, issue following command
```bash
terraform apploy -auto-approve
```

### Destroy the infrastructure
remember to delete the infrastructure when you finish your bootcamp in order to save money
```bash
terraform destroy -auto-approve
```