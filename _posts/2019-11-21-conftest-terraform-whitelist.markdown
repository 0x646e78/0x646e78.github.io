---
layout: post
title:  "Using Conftest to enforce Terraform allowed resources"
date:   2019-11-21 20:10:00 +1000
categories: security
---

I've just been playing with [conftest](https://github.com/instrumenta/conftest)
 as a means to enforce a whitelist of allowed Terraform resources. Conftest _"is
  a utility to help you write tests against structured configuration data"_ and
  uses the Open Policy Agent rego syntax.

The setup that I'm working with is a controlled CI environment, where agents 
run a docker build container which hosts the underlying build tools - such as
terraform, aws cli etc.  Makefiles are provided in this image also, which are
included in a projects build. We use Cloudformation for deployment of AWS
resources, and there is concern that people will start to use terraform for these,
which we want to discourage and possibly prevent.

After playing for the afternoon I got to an OK point with this. There are of
course issues - as the person running a build can insert abitrary commands in
their build steps they could call terraform direct to bypass my current
way of doing this - and so it is currently more of a helpful check than a strict
policy enforcement, but I'm sure this could be addressed when I spend some more
time on it.


### In the build agent:

First install Terrraform and Conftest, and then set the following configuration.

_/opt/policy/terraform/base.rego_
```
package main

whitelist = [
  "datadog",
  "pagerduty"
]

deny[msg] {
  resources := input.resource_changes[_].type
  not check_resources(resources, whitelist)
  allowed := concat(", ", whitelist)
  msg = sprintf("Terraform plan will change prohibited resources which are not in the following namespaces: %v", [allowed])
}

# Checks whether the plan will cause resources with certain prefixes to change
check_resources(resource, allowed_prefixes) {
  startswith(resource, allowed_prefixes[_])
}
```

_/opt/make/terraform.mk_
```

tf-init: ##Init state and vars
	@terraform init

tf-plan: tf-init ##Validate and check for changes
	@terraform version && \
	terraform validate && \
	terraform plan -out /tmp/plan.tf

tf-conftest: tf-plan ##Check the validation with conftest
	@terraform show -json /tmp/plan.tf | conftest -p /opt/policy/terraform/ test -

tf-clean: ##Remove files created during make
	@rm -f /tmp/plan.tf

tf-apply: tf-init tf-plan tf-conftest tf-clean ##Apply changes
	@terraform apply -auto-approve
```


### And now in a project:

_Makefile_
```
include /opt/make/terraform.mk
```

_in your build steps_
```
make tf-plan tf-conftest

#Release to prod
make tf-apply
```


Now when a build is run, conftest checks the terraform plan against it's
policy and if a resource has been defined which isn't in the 
whitelist, the build will fail.


```
...
...
Terraform will perform the following actions:

  # aws_ebs_volume.example will be created
  + resource "aws_ebs_volume" "example" {
      + arn               = (known after apply)
      + availability_zone = "us-east-2a"
      + encrypted         = (known after apply)
      + id                = (known after apply)
      + iops              = (known after apply)
      + kms_key_id        = (known after apply)
      + size              = 10
      + snapshot_id       = (known after apply)
      + tags              = {
          + "Name" = "ConfTestTest"
        }
      + type              = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------


FAIL - Terraform plan will change prohibited resources which are not in the following namespaces: datadog, pagerduty
make: *** [/opt/make/terraform.mk:20: tf-conftest] Error 1

$ 
```
