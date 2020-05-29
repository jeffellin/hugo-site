+++
title = "Tools every Kubernetes Developer should have"
date = 2020-05-28T13:35:15-04:00
tags = ["kubernetes"]
featured_image = ""
description = "Tools to make your life easier with Kubernetes. "
draft = "false"
+++



# Toolkits for Kubernetes

## K14s

[k14s](https://k14s.io) Is a suite of tools for managing your Kubernetes environment.


### Tools in the package

* **ytt**

* kbld 

* kapp 

* imgpkg 

* kapp-controller 

* vendir

* kwt

* terraform-provider-k14s #terraform

The one tool in the suite that I find indispensable is *ytt*. This tool allows easy templating of Kubernetes Yaml. This tool comes in handy for replacing image versions in manifests before applying deployment changes.


## K8s

If you are getting tired of the CLI, give [K9s](https://k9scli.io
) a try. It's a terminal-based UI to Kubernetes. You can view the status of all Kubernetes Objects, view logs, shell into containers and much more. 

## Octant

Looking for something similar but browser-based? Give [Octant](https://github.com/vmware-tanzu/octant) a try. 

## Visual Studio code

Editing YAML is a pain. [VS Code](https://code.visualstudio.com) is an extremely competent text editor from Microsoft. It has an extensive collection of plugins and support for Git source control integration. 

Download the base package, and be sure to install the following plugins.

* Docker
* Kubernetes
* Kubernetes Support

The plugins allow you to get remote visibility into running Docker containers, and Kubernetes clusters. Also, you get code completion and syntax checking.


## Cloud-native Buildpacks

Are you used to running *Cloud Foundry* ? Are you tired of writing Dockerfiles? [Cloud native buildpacks](https://buildpacks.io) are the solution. The buildpack is a curated container for running your app. One command will build the container and push it to the registry. No Dockerfile required.

```pack build ellinj/pcf-demo:a --builder cloudfoundry/cnb:bionic --publish```

## Docker

The underpinning of most Kubernetes deployments is [Docker](https://docs.docker.com/desktop/). Developers should have access to locally built, run, and test their images. A CI system only goes so far. Sometimes it best to run the container and debug on your desktop. 


## Kubectl

No list would be complete without [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/). This CLI is *THE CLI* for Kubernetes. Commands take the format.

`kubectl [command] [TYPE] [NAME] [flags]`

Get used to typing commands like:

`kubectl get pods`

and

`kubectl port-forward pal-tracker-development-6776c9ccc7-98fk2 8080:8080`

Here are two good references for kubectl commands

[Cheatsheat](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

[Unofficial Cheatsheet](https://unofficial-kubernetes.readthedocs.io/en/latest/user-guide/kubectl-cheatsheet/)

