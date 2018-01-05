+++
title = "Terraform on Google Cloud Engine Quickstart"
draft = false
date = "2017-11-23T20:00:00+01:00"
keywords = [ "Programming", "Cloud", "Infrastructure as Code", "DevOps", "Google Cloud Engine", "GCE", "terraform" ]
slug = "terraform_on_google_cloud_engine_quickstart"

[params]
  author = "Jannik Arndt"
+++

This is a quickstart for building something on Google Compute Engine without clicking any buttons (after you created the project).

<!--more-->

## Prerequisites

Install terraform:

```shell
$ brew install terraform
```

Install Google Cloud SDK:

```shell
$ brew cask install google-cloud-sdk
```

[create a new project](https://console.cloud.google.com/projectcreate) in the console
and [login](https://cloud.google.com/sdk/gcloud/reference/auth/login)

```shell
$ gcloud auth application-default login
```

If you are using IntelliJ IDEA, install the [HashiCorp Terraform Plugin](https://plugins.jetbrains.com/plugin/7808-hashicorp-terraform--hcl-language-support).

## Option A: Import a project

If you have created a project using the console, create a `config.tf` with the basic settings:

```shell
provider "google" {
    region      = "eu-central-1"
}

resource "google_project" "project" {}
```

Now run `terraform init` to download the google provider plugin. Now import the project via

```shell
$ terraform import google_project.project project-id-186346
```

You now have a corresponding `terraform.tfstate` file that contains the name, billing account and other info about your project.

## Option B: Create a new project from scratch

Make a new folder and create a `config.tf` file:

```shell
provider "google" {
  region      = "eu-central-1"
}

resource "google_project" "project" {
  name = "holisticon"
  project_id = "holisticon-123456"
  billing_account = "01B8C8-F33191-3DE337" // optional
}
```

Now run `terraform init` to download the google provider plugin. Next run `terraform apply` to create the project. Note that the `project_id` may not already exist. The `billing_account` is optional. Also you can only have a maximum of 12 projects at the same time.

## Adding people

So far you are the owner of the new project. Now you can create IAM roles and add other people to your project:

```shell
resource "google_project_iam_binding" "project_editors" {
  project = "${google_project.project.project_id}"
  role = "roles/editor"
  members = [
    "user:nice.coworker@holisticon.de",
  ]
}
```

You can find a description of all roles [here](https://cloud.google.com/iam/docs/understanding-roles#primitive_roles). Note that you [cannot grant the owner role through the API but only using the Cloud Platform Console](https://cloud.google.com/resource-manager/reference/rest/v1/projects/setIamPolicy).