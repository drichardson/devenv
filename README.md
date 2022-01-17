# Cloud Development Environments
Configure cloud compute instances for interactive developer machines.

# Bootstraping AWS
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


