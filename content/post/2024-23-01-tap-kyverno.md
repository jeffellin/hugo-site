+++
title = "Intro to Kyverno"
date = 2024-01-23T13:35:15-04:00
tags = ["kubernetes","kyverno","Tanzu","TAP" ]
featured_image = ""
description = "Intro to Kyverno"
draft = "false"
codeLineNumbers = true
codeMaxLines = 100
featureImage = "/wp-content/uploads/2024/kyverno.png"
+++

In my spare time, I've been delving into various software offerings within the CNCF landscape that I've heard about but haven't had the chance to thoroughly explore and experiment with in my own projects.

One such exploration is focused on Kyverno. Derived from the Greek word "govern," Kyverno is an intriguing CNCF incubating project. It facilitates policy management using YAML, aligning with the broader trend of adopting declarative and code-centric approaches in the Kubernetes ecosystem. Drawing parallels with the combination of OPA and Gatekeeper, Kyverno excels in enforcing policies during the admission of objects to Kubernetes clusters.

An illustrative example of Kyverno's functionality involves a straightforward policy requiring a Namespace to carry a specific label indicating its purpose, such as "Production" or "Development." This showcases Kyverno's ability to ensure consistency and organization in Kubernetes configurations.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-ns-purpose-label
spec:
  validationFailureAction: Enforce
  rules:
  - name: require-ns-purpose-label
    match:
      any:
      - resources:
          kinds:
          - Namespace
    validate:
      message: "You must have label `purpose` with value set on all new namespaces."
      pattern:
        metadata:
          labels:
            purpose: "?*"
```
This namespace would create properly.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: prod-bus-app1
  labels:
    purpose: production
```

This namespace would fail creation and not be admitted to the cluster.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: prod-bus-app1
  labels:
    team: awesome-prod-app
```

I am allowing namespaces to be created with any purpose, however the list of allowed values could be constrained by regular expressions.

## Anatomy of a Rule

![Anatomy of a Rule](/wp-content/uploads/2024/Kyverno-Policy-Structure.png)

A Kyverno Policy, composed in YAML as depicted above, comprises several key sections, each serving distinct purposes:

* **One or More Rules**: Each rule is designed to either match or exclude an object based on its name or specific properties.
* **Rule Actions**: Once a rule is triggered, it can undertake various actions, including object validation, object mutation, object generation, or image verification. This modular approach provides flexibility in shaping and managing Kubernetes resources based on defined criteria.

## Mutation
Kyverno empowers administrators to seamlessly mutate objects within a Kubernetes cluster. For instance, as a system administrator, ensuring that all images in the cluster are consistently fetched might be a priority. While the ideal scenario would involve developers explicitly adding the Always imagePullPolicy, Kyverno offers an additional layer of convenience by enabling automatic object mutation.

In practical terms, a rule can be defined in Kyverno, specifying that any object of type Pod should have its imagePullPolicy automatically set to Always. This illustrates how Kyverno streamlines the process of enforcing desired configurations across objects within the Kubernetes environment.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: always-pull-images
  annotations:
    policies.kyverno.io/title: Always Pull Images
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: >-
      By default, images that have already been pulled can be accessed by other
      Pods without re-pulling them if the name and tag are known. In multi-tenant scenarios,
      this may be undesirable. This policy mutates all incoming Pods to set their
      imagePullPolicy to Always. An alternative to the Kubernetes admission controller
      AlwaysPullImages.      
spec:
  rules:
  - name: always-pull-images
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        spec:
          containers:
          - (name): "?*"
            imagePullPolicy: Always
```

## Creation

Kyverno can also be used to create objects as a result of creation of another object.

For example, we would like to add a Quota to every new Namespace.  

The following example creates a new `ResourceQuota` and a `LimitRange` object whenever a new `Namespace` is created.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ns-quota
  annotations:
    ... 
spec:
  rules:
  - name: generate-resourcequota
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: v1
      kind: ResourceQuota
      name: default-resourcequota
      synchronize: true
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          hard:
            requests.cpu: '4'
            requests.memory: '16Gi'
            limits.cpu: '4'
            limits.memory: '16Gi'
  - name: generate-limitrange
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: v1
      kind: LimitRange
      name: default-limitrange
      synchronize: true
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          limits:
          - default:
              cpu: 500m
              memory: 1Gi
            defaultRequest:
              cpu: 200m
              memory: 256Mi
            type: Container
```
## Other Uses
In addition to the above use cases Kyverno has a few other capabilities.

1. Cleanup - Kyverno allows you to specify actions for object deletion. For instance, when a new version of a Deployment is created, it can initiate the creation of a new ReplicaSet with the desired replicas while scaling the current one down to zero.

2. [Image Verification](https://kyverno.io/policies/tekton/verify-tekton-taskrun-vuln-scan/)  - Kyverno facilitates image verification before execution. This involves ensuring that the image adheres to specified requirements, such as the necessity for a signed bundle and a vulnerability scan conducted by Grype, with no vulnerabilities exceeding a threshold of 8.0.  

For a comprehensive list of example Kyverno polies check [here](https://kyverno.io/policies/?policytypes=cleanUp)

## Installation.  

Installation of Kyverno is quite straightforward.  You can read about it in detail in the [Kyverno Docs](https://kyverno.io/docs/installation/)  

I have used Flux's ability to install Helm charts so that I can provision Kyverno and any associated policies via GitOps

```yaml
# First Install the Helm Repository that contains Kyverno
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: kyverno
  namespace: tanzu-helm-resources
spec:
  interval: 5m0s
  url: https://kyverno.github.io/kyverno/

```
```yaml
---
# Install a fixed version of Kyverno
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kyverno-release
  namespace: tanzu-helm-resources
  annotations:
    kapp.k14s.io/change-group: "crossplane/helm-install"
    kapp.k14s.io/change-rule: "upsert after upserting crossplane/helm-repo"
spec:
  chart:
    spec:
      chart: kyverno
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: kyverno
      version: 3.1.4
  install:
    createNamespace: true
  interval: 10m0s
  ```

  ## Provisioning Namespaces

  In some of my past discussion of Tanzu Application Platform (TAP) Installation I pointed out a crucial step that must be peformed before a developer canm start using a namespace.
  
  There are multiple objects that need to be provisioned.  
  
  These include:
  * Secret to reach Github
  * Scan Policy
  * Registry Secret
  * Tekton Testing Pipeline
  * RBAC

In early versions of TAP I used carvel's ability to copy a remote Git repo into a namespace.

The below example creates a namespace and then creates a Carvel `App` to keep that namespace in sync with the contents of 

* clusters/common/app-contents/dev-namespace
* clusters/common/app-contents/test-scan-namespace

The deploy `intoNS` at the very end accomplishes this.

```yaml
#@ load("@ytt:data", "data")
---
apiVersion: v1
kind: Namespace
metadata:
  name: canary
---
apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: dev-ns-canary
  namespace: tap-install
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting tap"
spec:
  serviceAccountName: tap-install-gitops-sa
  syncPeriod: 1m
  fetch:
  - git:
      url: #@ data.values.git.url
      ref: #@ data.values.git.ref
  template:
  - ytt:
      paths:
      - clusters/common/app-contents/dev-namespace
      - clusters/common/app-contents/test-scan-namespace
      valuesFrom:
        - secretRef:
            name: tap-install-gitops
  deploy:
  - kapp: 
      intoNs: canary
```

values for the Git url and Git are configurable via the `tap-instgall-gitops` secret

Later versions of TAP introduced a controller that allows you to specify a Git repo to copy the contents into namespaces.  While this worked well it did require some configration within the `tap-values`. In addition it was assumed that the default setup would create the namespace and maintain its entire lifecycle. It did not have the ability to account for namespaces that were created outside of the tap installation.

## Kyverno to provision namespaces.

Next, I will show you two possible ways of using Kyverno to automatically configure your workspaces.

### Use Kyverno policy to create what you need.
We can apply the required objects directly using Kyverno policy.  

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ns
   ..
spec:
  rules:
  - name: generate-gitsecret
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: secretgen.carvel.dev/v1alpha1
        kind: SecretImport
        metadata:
        name: git-https
        annotations:
          tekton.dev/git-0: https://github.com
        spec:
        fromNamespace: tap-install
  - name: generate-scanpolicy
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: scanning.apps.tanzu.vmware.com/v1beta1
      kind: ScanPolicy
      metadata:
      name: lax-scan-policy
      labels:
          app.kubernetes.io/part-of: scan-system #! This label is required to have policy visible in tap-gui, but the value can be anything
      spec:
        regoFile: |
            package main

            # Accepted Values: "Critical", "High", "Medium", "Low", "Negligible", "UnknownSeverity"
            notAllowedSeverities := ["UnknownSeverity"]
            
            ignoreCves := []

            contains(array, elem) = true {
            array[_] = elem
            } else = false { true }

            isSafe(match) {
            severities := { e | e := match.ratings.rating.severity } | { e | e := match.ratings.rating[_].severity }
            some i
            fails := contains(notAllowedSeverities, severities[i])
            not fails
            }

            isSafe(match) {
            ignore := contains(ignoreCves, match.id)
            ignore
            }

            deny[msg] {
            comps := { e | e := input.bom.components.component } | { e | e := input.bom.components.component[_] }
            some i
            comp := comps[i]
            vulns := { e | e := comp.vulnerabilities.vulnerability } | { e | e := comp.vulnerabilities.vulnerability[_] }
            some j
            vuln := vulns[j]
            ratings := { e | e := vuln.ratings.rating.severity } | { e | e := vuln.ratings.rating[_].severity }
            not isSafe(vuln)
            msg = sprintf("CVE %s %s %s", [comp.name, vuln.id, ratings])
            }
```
This approach has a drawback as it necessitates modifying the policy each time there are changes to the namespace contents. Personally, I prefer the method of employing [Kapp Controller](https://carvel.dev/kapp-controller/) from the Carvel Project to effectively manage the contents within the namespace.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ns-kapp
  annotations:
    ...
    policies.kyverno.io/description: >-
      To better control the number of resources that can be created in a given namespace This policy will generate App and use GitOps to provision the objects needed.
spec:
    - name: generate-kapp
      match:
        any:
        - resources:
            kinds:
            - Namespace
      generate:
        apiVersion: kappctrl.k14s.io/v1alpha1
        kind: App
        metadata:
        name: "{{request.object.metadata.name}}-ns"
        namespace: tap-install
        spec:
          serviceAccountName: tap-install-gitops-sa
          syncPeriod: 1m
          fetch:
          - git:
              url: https://github.com/tanzu-end-to-end/tap-gitops-reference
              ref: main
          template:
          - ytt:
              paths:
              - clusters/common/app-contents/dev-namespace
              - clusters/common/app-contents/test-scan-namespace
              valuesFrom:
                - secretRef:
                  name: tap-install-gitops
          deploy:
          - kapp: 
              intoNs: "{{request.object.metadata.name}}"
```
By doing this we can externalize some parameters from the input object. We can use `"{{request.object.metadata.name}}"` to indicate the value for `intoNS`

We leave the `valuesFrom` reference because this allows us to use a secret to populate values. For example we may need to populate a CA and we can do so from the value within the secret. [Grype Config Map] (https://github.com/tanzu-end-to-end/tap-gitops-reference/blob/main/clusters/common/app-contents/test-scan-namespace/gryp-ca-configmap.yaml_

Using this approach it is also possible to change the behavior by pointing to different git repos based on the value provided in the `purpose` label that we marked as required in the `require-ns-purpose-label` Cluster Policy.
## Conclusion

In summary, Kyverno emerges as a valuable tool for Kubernetes users seeking an efficient, flexible, and secure policy management solution. Its Policy as Code approach, dynamic enforcement, and community support make it a compelling choice for organizations aiming to enhance their Kubernetes deployment's reliability and security. 

**Kyverno allows for:**

1. Policy as Code (PaC): Kyverno allows the definition of Kubernetes policies using code, promoting a "policy as code" approach. This enables version control, collaboration, and easier management of policies alongside the application code.

2. Dynamic Policy Enforcement: Kyverno dynamically enforces policies in real-time as resources are created or updated in the Kubernetes cluster. This ensures that policies are consistently applied, reducing the risk of misconfigurations and security vulnerabilities.

3. Simplified Policy Management: Kyverno simplifies policy management by providing a centralized and declarative approach. Policies can be defined, reviewed, and audited easily, contributing to better governance and operational efficiency.

