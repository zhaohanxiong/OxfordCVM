# store state in s3 for provisioning and tracking
terraform {
    backend "s3" {
        bucket = "terraformeksproject"
        key    = "state.tfstate"
    }
}
