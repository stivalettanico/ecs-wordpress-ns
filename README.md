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

# Terraform structure




