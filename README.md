# Deploy wordpress into ECS Fargate with Terraform
The idea behind this project came from the need to build a simple Wordpress application in just few simple steps, without the need to manage how much capacity in terms of computation I needed, and ideally by using microservices.

At that time, I was already familiar with AWS, I was also studying to get my first AWS certificate but I never had the chance to work with microservices. So I sayd to myself, why don't you build a simple website by using ECS? 

Amazon ECS is a fully managed container orchestration service that makes it easy for you to deploy, manage, and scale containerized applications. 
For more info:

https://aws.amazon.com/ecs/

I started doing my researches and came up with a very interesting article from AWS that explained how to deploy a Wordpress application directly in ECS by using Cloudformation: 

https://aws.amazon.com/blogs/containers/running-wordpress-amazon-ecs-fargate-ecs/

So I though, here we are! job done, 
I followed the guide, made some changes here and there, and I had a fully working Wordpress website deployed in AWS. Simply Amazing!!

Recently I decided redpedloy the application again, but rather than using Cloudformation I decided to refactor everything to Terraform. I know, I could have used some tools or even the "famous" ChatGPT to assist me in this journey, but since my main objective was to use improve my Terraform skills, I decided to do it manually step by step.

# Architecture
The architecture is based on the one provided by AWS in the article mentioned above. Please find below a picture that I took from the blog post.

![image](https://user-images.githubusercontent.com/102290995/219600285-dfd87ad3-a5f5-4776-9aac-fca051757e10.png)

The main different between my project and the one provided by AWS is that it's possible to choose how many subnets can be created. Everything has been fully parametrised by using Terraform variables. 

In terms of architecture, the application is a classic 3 tiers application where:
1. The Frontend layer contains the public subnets, and it is where the internet facing ALB and the NAT gateway are deployed.
2. The Appliction layer is where the ECS cluster and an EFS driver are located.
3. The Database layer is where the RDS instance is deployed.

For this project, I kept things simple since both the ECS cluster and the DB share the same private subnets in multi AZs way. 
In a production environment, ECS and DB should be deployed in a dedicated and separate subnets with the NACL in place that will allow only the required traffic between the two subnets.  
Segregationg the subnets and the workload is required in order to adhere to the principals of zero trust and the AWS well architected framework. 
In terms of the HA, we have a single RDS instance. In a production environment is strongly advised to deploy the DB in multiple AZs and ideally, one or more read only replica so that the load can be evenly distributed.

## Run terraform command with var-file

Create a file with the required variables. Please note, it is higly reccomanded to create a tfvars file for each environment. In the below example I am adding a tfvar file only for the DEV environment.

```bash
$ cat environments/dev/terraform.dev.tfvars

################################################################################
# Root
################################################################################
//current_env                 = terraform.workspace
aws_target_region           = "eu-west-2"
project_name                = "wordpress"
aws_account_id              = "<00000000000000>"
aws_role                    = "deploy-terraform-role"
account_name                = "<myaccount_name>"

################################################################################
# network module
################################################################################
vpc_cidr_range              = "10.0.0.0/16"
public_subnet_cidr_range    = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidr_range   = ["10.0.2.0/24", "10.0.3.0/24"]
alb_port                    = 80
alb_target_type             = "ip"
alb_protocol                = "HTTP"  
alb_health_check_port       = 8080

################################################################################
# data module
################################################################################
db_port                     = 3306
db_allocated_storage        = 20
db_name                     = "wordpress"
db_engine                   = "mysql"
db_engine_version           = "5.7"
db_instance_class           = "db.t3.micro"
db_username                 = "admin"
db_password                 = "password"
efs_creation_token          = "efs-wordpress"
efs_encrypted               = true
efs_throughput_mode         = "bursting"
efs_performance_mode        = "generalPurpose"  
efs_path                    = "/bitnami"

################################################################################
# ecs-cluster module
################################################################################
container_name              = "wordpress"
volume_name                 = "wordpress_volume"
container_port              = 8080
image_name                  = "bitnami/wordpress"
container_path              = "/bitnami/wordpress"
task_number                 = 4

$ terraform plan -var-file=config/dev.tfvars
```

# Terraform structure


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.30 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data"></a> [data](#module\_data) | ./modules/data | n/a |
| <a name="module_ecs-cluster"></a> [ecs-cluster](#module\_ecs-cluster) | ./modules/ecs-cluster | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | this is the account name where we want to deploy our application | `string` | `""` | no |
| <a name="input_alb_health_check_port"></a> [alb\_health\_check\_port](#input\_alb\_health\_check\_port) | n/a | `any` | n/a | yes |
| <a name="input_alb_port"></a> [alb\_port](#input\_alb\_port) | n/a | `any` | n/a | yes |
| <a name="input_alb_protocol"></a> [alb\_protocol](#input\_alb\_protocol) | n/a | `any` | n/a | yes |
| <a name="input_alb_target_type"></a> [alb\_target\_type](#input\_alb\_target\_type) | n/a | `any` | n/a | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | this is the account id where we want to deploy our application | `string` | `""` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | this is the role to be used in order to deploy our application | `string` | `""` | no |
| <a name="input_aws_target_region"></a> [aws\_target\_region](#input\_aws\_target\_region) | this is the region where we want to deploy our application | `string` | `""` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | n/a | `any` | n/a | yes |
| <a name="input_container_path"></a> [container\_path](#input\_container\_path) | n/a | `any` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | n/a | `any` | n/a | yes |
| <a name="input_current_env"></a> [current\_env](#input\_current\_env) | this is the environment(workspace) where we want to deploy the application | `string` | `""` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | n/a | `any` | n/a | yes |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | n/a | `any` | n/a | yes |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | n/a | `any` | n/a | yes |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | n/a | `any` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `any` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | n/a | `any` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | n/a | `any` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | n/a | `any` | n/a | yes |
| <a name="input_efs_creation_token"></a> [efs\_creation\_token](#input\_efs\_creation\_token) | n/a | `any` | n/a | yes |
| <a name="input_efs_encrypted"></a> [efs\_encrypted](#input\_efs\_encrypted) | n/a | `any` | n/a | yes |
| <a name="input_efs_path"></a> [efs\_path](#input\_efs\_path) | n/a | `any` | n/a | yes |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | n/a | `any` | n/a | yes |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | n/a | `any` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | n/a | `any` | n/a | yes |
| <a name="input_private_subnet_cidr_range"></a> [private\_subnet\_cidr\_range](#input\_private\_subnet\_cidr\_range) | n/a | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `any` | n/a | yes |
| <a name="input_public_subnet_cidr_range"></a> [public\_subnet\_cidr\_range](#input\_public\_subnet\_cidr\_range) | n/a | `any` | n/a | yes |
| <a name="input_task_number"></a> [task\_number](#input\_task\_number) | n/a | `any` | n/a | yes |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | n/a | `any` | n/a | yes |
| <a name="input_vpc_cidr_range"></a> [vpc\_cidr\_range](#input\_vpc\_cidr\_range) | n/a | `any` | n/a | yes |

## Outputs

No outputs.





