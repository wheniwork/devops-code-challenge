# DevOps Code Challenge

This Kubernetes challenge was designed to be completed on Linux or MacOS with the following dependencies:

 - Minikube v1.21 or newer
 - GNU Make 4.3 or newer

Generating a `CHANGELOG.md` also requires https://github.com/conventional-changelog/standard-version.

If you do not want to install these dependencies on your local machine, a `Containerfile` is provided with
all of the necessary tools.

## Scenario

You've been handed half of a kubernetes blog deployment and your goal is to complete it. The purpose of the
project is to get Wordpress running in Minikube and using a MySQL database. Wordpress is not our main platform,
but we wanted an example where errors would be easy to find on Google, and the resources in `kubernetes/` are
based on resources from the kubernetes documentation.

This is not meant to be incredibly challenging and should not take more than an hour or two of your time, but
requires a general understanding of git and kubernetes in order to deploy and debug the example. Please let
HR know if you have any questions.

All of our requirements are documented and tests can be run using the `make test` target. We do not have any
hidden tests. Please do not remove any tests. If you find and fix any bugs within the tests,
please describe your changes. Testing will be performed in a clean minikube cluster meeting the
version requirements above. Tests can also be run individually, please see `make help` for more.

Please provide HR with a link to a public Git repository containing your solution, hosted somewhere
such as Github.com or Gitlab.com. Please do not submit any ZIP archives or Google Drive folders of your code.

### Contents

This repository contains:

- a broken MySQL statefulset resource
- the stub of a Wordpress deployment resource
- a Makefile to deploy the YAML and run tests
- a Containerfile with all of the necessary tools to complete this challenge

### Requirements

1. fix the MySQL stateful set
2. add a stateless Wordpress deployment matching the selectors on the `wordpress` service
3. add liveness and readiness probes to all containers
4. make sure all pods start up correctly and remain healthy after `make deploy`
5. make sure all tests pass during `make test`
6. clone this repository, commit your changes into a `feature/` branch, and push to a public git repository
    - please make sure the link you provide is publicly visible

### Bonus Points

1. attach the provided `PersistentVolumeClaim` to `/var/www/html` in the Wordpress deployment to make it stateful
2. apply resource limits to the kubernetes pods
3. include a kubernetes Ingress resource for the AWS ALB ingress controller
    - we use https://github.com/kubernetes-sigs/aws-load-balancer-controller for ingress
4. a branch with conventional commit history and a CHANGELOG file
    - we typically use https://github.com/conventional-changelog/standard-version to generate the CHANGELOG file
