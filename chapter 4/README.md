## Terraform Module

This chapter is about terraform module. A terraform module is just a directory that contains
terraform code. From previous chapters we know that we have a common part which is web-cluster, which we
can extrat this folder to a dedicated module and then inside stage environment we can just reference this
module. Furthermore, if you have a production environment, instead of writing new code. We can just refer
to the module again. Following is the final folder structure of the new terraform code
```md
chapter\ 4
├── README.md
├── global
│   └── s3
│       ├── backend.hcl
│       ├── main.tf
│       └── outputs.tf
├── modules
│   └── services
│       └── web-cluster
│           ├── main.tf
│           ├── outputs.tf
│           ├── user-data.sh
│           └── variables.tf
└── stage
    ├── data-stores
    │   └── mysql
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    └── services
        └── web-cluster
            └── main.tf
```
So in the stage environment, notice we only have one file which will reference the module. Another thing
should be aware with is that `whenever you add a module to terraform configuration or modify source code you need to run terraform init first`
```bash
terraform init -backend-config="../../../global/s3/backend.hcl"
```