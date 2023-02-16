# Deploy wordpress into ECS Fargate with Terraform
The idea behind this project came from the need to build a simple Wordpress application in just few simple steps without the need to manage how much capacity in term of computation I needed.

At that time I was already familiar with AWS, but maninly with EC2 instances and never had the chance to work on microservices. So I sayd to myself..... why don't you build a simple website by using ECS? 

I started doing my researches and came up with a very interesting article from AWS that explained how to deploy a Wordpress application in ECS: 

https://aws.amazon.com/blogs/containers/running-wordpress-amazon-ecs-fargate-ecs/

so I said, here we are! job done, 
I followed the guide, maybe some changes and here and there and I had a fully working Wordpress website deployed in AWS. Amazing!!

Recently I decided that I wanted the Wordpress application to be deployed by using Terraform rather than Cloudformation. I know, I could have used some tools or even the "famous" ChatGPT to assist me in this journey.....but since my main objective was to use improve my Terraform skills, I decided to do it manually.

# Architecture


