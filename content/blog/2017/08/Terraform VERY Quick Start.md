+++
title = "VERY Quick Start: Terraform"
draft = false
date = "2017-08-06T17:20:00+01:00"
keywords = [ "Cloud", "Infrastructure as Code" ]
slug = "very_quick_start_terraform"

[params]
  author = "Jannik Arndt"
+++

> This post contains the absolut essence from the Terraform Getting Started Guide:
> https://www.terraform.io/intro/getting-started/install.html

<!--more-->

## Preparation
```bash
brew install terraform
```

Create `aws.tf`:
```json
provider "aws" {
  region     = "us-east-1" 
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631" // https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "t2.micro"
}
```
AMI = [Amazon Machine Images](https://cloud-images.ubuntu.com/locator/ec2/)

AWS credentials are stored in environment vars:
```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

## Init

```bash
$ terraform init
...
Terraform has been successfully initialized!
...
```

```bash
$ terraform plan -out planfile
  + aws_instance.example
      ami:                          "ami-2757f631"
      associate_public_ip_address:  "<computed>"
...
```

```bash
$ terraform apply planfile
aws_instance.example: Creating...
...
aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Still creating... (20s elapsed)
aws_instance.example: Still creating... (30s elapsed)
aws_instance.example: Still creating... (40s elapsed)
aws_instance.example: Creation complete (ID: i-00b2e1a29daee4371)
```

```bash
$ terraform show
aws_instance.example:
  id = i-00b2e1a29daee4371
  ami = ami-2757f631
  associate_public_ip_address = true
```

## Change

`ami-2757f631` (Ubuntu 16.04 LTS AMI) => `ami-b374d5a5` (Ubuntu 16.10 AMI)

In `aws.tf`:
```json
provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
}
```

```bash
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
aws_instance.example: Refreshing state... (ID: i-00b2e1a29daee4371)
...
-/+ aws_instance.example (new resource required)
      ami:                          "ami-2757f631" => "ami-b374d5a5" (forces new resource)
      associate_public_ip_address:  "true" => "<computed>"
...
```

```bash
$ terraform apply
aws_instance.example: Refreshing state... (ID: i-00b2e1a29daee4371)
aws_instance.example: Destroying... (ID: i-00b2e1a29daee4371)
...
aws_instance.example: Destruction complete
aws_instance.example: Creating...
  ami:                          "" => "ami-b374d5a5"
  associate_public_ip_address:  "" => "<computed>"
...
aws_instance.example: Creation complete (ID: i-05a8f2e88ae0faace)
```

## Destroy

```bash
$ terraform plan -destroy
Refreshing Terraform state in-memory prior to plan...
...
  - aws_instance.example
...
```

```bash
$ terraform destroy
aws_instance.example: Refreshing state... (ID: i-05a8f2e88ae0faace)
...

  - aws_instance.example

Terraform will delete all your managed infrastructure, as shown above. 
There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.example: Destroying... (ID: i-05a8f2e88ae0faace)
aws_instance.example: Destruction complete

Destroy complete! Resources: 1 destroyed.

```

## Assigning an IP to the instance

In `aws.tf`:
```json
provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}
```

```bash
$ terraform apply planfile 
aws_instance.example: Creating...
...
aws_instance.example: Creation complete (ID: i-0478b3c5b6a085287)
aws_eip.ip: Creating...
...
aws_eip.ip: Creation complete (ID: eipalloc-6be79a58)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```
```bash
$ terraform refresh
aws_instance.example: Refreshing state... (ID: i-0478b3c5b6a085287)
aws_eip.ip: Refreshing state... (ID: eipalloc-6be79a58)
```
```bash
$ terraform show
aws_eip.ip:
  id = eipalloc-6be79a58
  association_id = eipassoc-590d9e6c
  domain = vpc
  instance = i-0478b3c5b6a085287
  network_interface = eni-73845aa6
  private_ip = 172.31.17.98
  public_ip = 52.204.255.194
  vpc = true
aws_instance.example:
  id = i-0478b3c5b6a085287
  ami = ami-b374d5a5
  associate_public_ip_address = true
```

## Dependencies
The order in which resources are created is determined by terraforms analysis of (implicit) dependencies. Dependencies can also be defined explicitly, for example:
```json
resource "aws_eip" "ip" {
  instance   = "${aws_instance.example.id}"
  depends_on = ["aws_instance.example"] # <- explicit dependency
}
```
To view a dependency graph:
```bash
$ terraform graph > graph.dot
```
And open with graphviz:
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 617.8 332">
  <g class="graph" transform="translate(4 328)">
    <path fill="#fff" stroke="transparent" d="M-4 4v-332h617.8V4H-4z"/>
    <g class="node">
      <path fill="none" stroke="#000" d="M387-180h-76.7v36H387v-36z"/>
      <text x="348.6" y="-157.8" text-anchor="middle" font-family="Times,serif" font-size="14">
        aws_eip.ip
      </text>
    </g>
    <g class="node">
      <path fill="none" stroke="#000" d="M419.2-108H278v36h141.2v-36z"/>
      <text x="348.6" y="-85.8" text-anchor="middle" font-family="Times,serif" font-size="14">
        aws_instance.example
      </text>
    </g>
    <g stroke="#000" class="edge">
      <path fill="none" d="M348.6-143.8v25.4"/>
      <path d="M352-118.4l-3.4 10-3.5-10h7z"/>
    </g>
    <g class="node">
      <path fill="none" stroke="#000" d="M348.6-36L270-18l78.6 18 78.6-18-78.6-18z"/>
      <text x="348.6" y="-13.8" text-anchor="middle" font-family="Times,serif" font-size="14">
        provider.aws
      </text>
    </g>
    <g stroke="#000" class="edge">
      <path fill="none" d="M348.6-71.8v25.4"/>
      <path d="M352-46.4l-3.4 10-3.5-10h7z"/>
    </g>
    <g class="node">
      <ellipse cx="191.6" cy="-234" fill="none" stroke="#000" rx="191.7" ry="18"/>
      <text x="191.6" y="-229.8" text-anchor="middle" font-family="Times,serif" font-size="14">
        [root] meta.count-boundary (count boundary fixup)
      </text>
    </g>
    <g stroke="#000" class="edge">
      <path fill="none" d="M230.4-216.2l70.7 32.4"/>
      <path d="M302.6-187l7.6 7.4-10.5-1 3-6.3z"/>
    </g>
    <g class="node">
      <ellipse cx="505.6" cy="-234" fill="none" stroke="#000" rx="104.3" ry="18"/>
      <text x="505.6" y="-229.8" text-anchor="middle" font-family="Times,serif" font-size="14">
        [root] provider.aws (close)
      </text>
    </g>
    <g stroke="#000" class="edge">
      <path fill="none" d="M468.8-217c-21.7 9.8-49.3 22.5-72.6 33.2"/>
      <path d="M397.4-180.5l-10.6 1 7.6-7.4 3 6.7z"/>
    </g>
    <g class="node">
      <ellipse cx="348.6" cy="-306" fill="none" stroke="#000" rx="46.9" ry="18"/>
      <text x="348.6" y="-301.8" text-anchor="middle" font-family="Times,serif" font-size="14">
        [root] root
      </text>
    </g>
    <g stroke="#000" class="edge">
      <path fill="none" d="M318.3-292c-22.4 10-53.3 24.3-79 36"/>
      <path d="M240.7-252.7l-10.6 1 8-7.3 3 6.3z"/>
    </g>
    <g stroke="#000" class="edge">
      <path fill="none" d="M379-292l80.5 37"/>
      <path d="M461.2-258.2l7.6 7.3-10.6-1 3-6z"/>
    </g>
  </g>
</svg>

## Provisioning/Bootstrapping
> https://www.terraform.io/docs/provisioners/index.html

Change `aws.tf`:
```json
resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
  
  # add provisioner
  provisioner "local-exec" {
      command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}

# add output
output "ip" {
  value = "${aws_eip.ip.public_ip}"
}
```
Provisioners are only run, when a resource is first created!
```bash
$ terraform destroy
...
$ terraform apply
...
Outputs:

  ip = 50.17.232.209
```

