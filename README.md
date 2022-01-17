# AWS Development Environments
Configure cloud compute instances for interactive developer machines.

# Setup

- AWS account
- [aws cli](https://aws.amazon.com/cli/) - configure it to use your AWS account
- [terraform](https://www.terraform.io/downloads)

Optional: manually delete all default VPCs since they will not be used. You can
view all your VPCs using [EC2 Global View](https://console.aws.amazon.com/ec2globalview/home).

# Bootstraping Terraform
The S3 bucket and DynamoDB table for the Terraform S3 backend need to be
created before anything else. Do this by going to bootstrap and running:

    terraform init
    terraform apply

The bootstrap code is the only piece that uses a local Terraform state, since
the S3 backend isn't setup before this point.

# Deployments
Once bootstrap is deployed, you can deploy one of the environments with:

    terraform init
    terraform apply

# Creating your own Developer Environment

Select an AWS region with the lowest ping to make your interactive terminal
experience feel as responsible as possible. Ping the instance after you set it
up. If the ping is too high, try another region.

- Great: <20ms
- Meh: ~80ms
- Sloooow: >150ms

