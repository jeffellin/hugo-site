---
id: 710
title: Concourse and Secret Management
date: 2019-03-15T16:41:34+00:00
author: ellinj
layout: post

permalink: /2019/03/15/concourse-and-secret-management/
categories:
  - concourse
tags:
  - concourse
---

One aspect of creating good CI/CD pipelines is the management of passwords and other credentials required for deployment.

<p data-source-line="5">
  A typical concourse pipeline will poll for updates in a git repo, do a build and then push the results to a PaaS such as Kubernetes or Cloud Foundry.
</p>

<h1 id="a-working-example" data-source-line="7">
  <a class="anchor" href="#a-working-example"><span class="octicon octicon-link"></span></a>A Working Example.
</h1>

<p data-source-line="9">
  For this example, we will use <code>bucc</code>. <code>bucc</code> is an all in one deployment of Bosh, UAA, Credhub, and Concourse. If you don&#8217;t have access to a working Concourse/Credhub environment, this is an excellent place to start.
</p>

<ol data-source-line="11">
  <li>
    <p>
      Install bucc per the documentation in <a href="https://github.com/starkandwayne/bucc">here</a>.
    </p>
  </li>
  
  <li>
    <p>
      Install Credhub cli from <a href="https://github.com/cloudfoundry-incubator/credhub-cli/releases">here</a>
    </p>
  </li>
</ol>

<h2 id="adding-a-secret-to-concourse" data-source-line="16">
  <a class="anchor" href="#adding-a-secret-to-concourse"><span class="octicon octicon-link"></span></a>Adding a secret to Concourse.
</h2>

<p data-source-line="18">
  Concourse will retrieve credentials from Credhub by looking them up based on their path.
</p>

```bash
/concourse/TEAM_NAME/PIPELINE_NAME/s3-password
/concourse/TEAM_NAME/s3-password
```    

<p data-source-line="25">
  Global credentials for a team can be placed directly under the team name. Credentials for a specific pipeline can be organized under the team name/pipeline name.
</p>

```bash
-> credhub set -n /concourse/main/cf-password --type value --value foobar
id: 1fc1da07-4938-47d8-a7c4-1f442a61dc33
name: /concourse/main/cf-password
type: value
value: <redacted>
version_created_at: "2019-03-15T15:07:00Z"
```    

<p data-source-line="36">
  Properties can be referenced in a pipeline using standard property replacement in Concourse
</p>

```yaml
---
jobs:
- name: job-hello-world
  public: true
  plan:
  - task: hello-world
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      run:
        path: env
      params:
        CF_PASSWD: ((cf-password))
```

<p data-source-line="56">
  Running this job should reveal the password.
</p>

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOME=/root
CAT_NAME=foobar
USER=root
```    

<h2 id="using-other-secret-types" data-source-line="65">
  <a class="anchor" href="#using-other-secret-types"><span class="octicon octicon-link"></span></a>Using other Secret types.
</h2>

<p data-source-line="67">
  Credhub can store other types of secrets besides just key-value pairs. Examples include SSH keys, JSON structures, and Certificates. A complete list of types are available <a href="https://github.com/cloudfoundry-incubator/credhub/blob/master/docs/credential-types.md">here</a>.
</p>

<p data-source-line="69">
  An SSH Key contains two parts. <code>public_key</code> and <code>private_key</code>. It can be imported as follows.
</p>

    credhub set --type ssh --name /concourse/main/ssh -p '-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAwGwcKp6LJqCmwz63HKGjhDhrsHJbn/bnWnvSE0oqPCic/LnA\ncY0qlvs4DbV+a7fYRDpvYfVAGQj277CkCnoEWKc6meiH+1PHcLJdOhKWSHNSkZrA\ntQ1Wb6MsVpXejpo4YzIiyLzaW4sXmz0bhxdkPWLRQAKr34fKJ27rOIJXDFTR1Bt8\nzz0As0R72R11o2GcnVjarR/3TAK+/ADkzAPrMMz9o+1J1wZD2YNBANs1dPh/IxZZ\nwWfqwc7JXCYKVFB+Xt7UpAam5UYt8gQ0lJnnNU5+TUhaUU5LenwNANmG4tLUHzqy\nYkUtSPhJ/BbNjYlKUnsN72ystrqPkmDPDP6g+wIDAQABAoIBAHwONyqTBItmz5zY\n9h0TaOR5q5QaZk//UrDXW1zsV8ZpOK0G5LdQl8C3PjA4bsTrxhZWxjCVeTmquelW\nLKxEdkDhr7pCXEkAfnh9xfUGvrT/BKCy8MLJUoyu2osIHHA7pVbun9ZjSzPxvMps\n3y59OjcJWna2QjDezsoVjLjl71EWz3Bk42gwZ3b4bBGlAgSgssL78E5xU9sYLGQP\ntKDsfU4OOB2VSdDsqpOiYyc5246GG8bbSmxbkmtWqL42iUvlnQptNanHAjphPWC+\nIFakDW8pugjFoGOpDW6jnzZEqEywFtmvpXd6jLeBKjBc6vtPODWbNN0fARdwo/An\noRPl6sECgYEA64eLHT3RMlMRxfjEKk3mQe8+qAVU5L92rzWgR9qgvANNlb4RFONU\nuwOzG9Tkv/vtWcR70LQY5KN2hJixCs1DyJgfPWIzrR6iPhc6aN4r48SjygDhFlPw\no6+qBpliHSNKSUao0u3+Bdk2LcYfqfXU+qjGKCXpl+t09W+/M2W3r0kCgYEA0SVy\nIOmjvm69dvj9ZSi6AbzSOP2gKWBXYG3qxpNlLq121mnEBf6JNagyKTvITCxT9bd0\n8DNYrVN8nxWF3nrROvmCGtBTNLVW5MRZYoBh0o/Qh1nCXCUODy7Vhyf4WtXNsGyu\nq3lqcJdZA791gdGpk+e6miuYFH0HcRNRKa0yWiMCgYBgvS1wd0GDcAcuzzyTO6fF\nkSSlEnuJ8PIoiNgqayv1zU2CoayWbcERhzV7yvehuzID2uYYFMDcuB8n2ydsjl62\n93RtW/Zpttlgs120UPyp8sxrXe0VpKiEMtSdHUblPOd4LWOOL15UvKC6MFQ1FNnD\nkqrBNsE5OuaxIJLh43eMsQKBgCCkvJSAgws1E6NfJ4XDfozI4PL+OyJaJCkr3soR\ntWg8sOC0b2EUImxajUG8T/37qTsf4EOhcATVlAzsehGIj+GpkfIHdAU1DJP2RZFH\nQn1v7vdBPkHNks0x3SgUSAI9frY7sGOZNtDN/pnEJ14U0GgCcjCf/0OrZB71CeT8\nYHCLAoGBAKY+kEMkX3drGj4BtCtJgt6nv3KZ/j7GJTl8M+brhBjH0fCtuZJgg7sP\nhukUE4Yb/qd1zLnFmUfepikow2qKhVzzdOhsdIR44BagqJzAS2jEkV/0m5PEABr3\nhfIpaY7w/RZ4Uid/5qGrJSWQnh00c+VqvVSCbfqnIeM4lwp9+slY\n-----END RSA PRIVATE KEY-----\n' -u 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAbBwqnosmoKbDPrccoaOEOGuwcluf9udae9ITSio8KJz8ucBxjSqW+zgNtX5rt9hEOm9h9UAZCPbvsKQKegRYpzqZ6If7U8dwsl06EpZIc1KRmsC1DVZvoyxWld6OmjhjMiLIvNpbixebPRuHF2Q9YtFAAqvfh8onbus4glcMVNHUG3zPPQCzRHvZHXWjYZydWNqtH/dMAr78AOTMA+swzP2j7UnXBkPZg0EA2zV0+H8jFlnBZ+rBzslcJgpUUH5e3tSkBqblRi3yBDSUmec1Tn5NSFpRTkt6fA0A2Ybi0tQfOrJiRS1I+En8Fs2NiUpSew3vbKy2uo+SYM8M/qD7'
    
    

<p data-source-line="76">
  You can now access the ssh key in your script.
</p>

```yaml
---
jobs:
- name: job-hello-world
  public: true
  plan:
  - task: hello-world
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      run:
        path: env
      params:
        CAT_NAME: ((ssh.private_key))
```    

<ul data-source-line="96">
  <li>
    You must flatten the key to a single line before importing it.
  </li>
</ul>

```bash
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' key.txt
```    

<p data-source-line="102">
  alternatively you can pass a file containing the key to import.
</p>

<h3 id="using-ssh-keys" data-source-line="104">
  <a class="anchor" href="#using-ssh-keys"><span class="octicon octicon-link"></span></a>Using SSH keys
</h3>

<p data-source-line="106">
  A typical use case in concourse is polling git for updated commits.
</p>

```yaml
---
resources:
- name: my-project-resource
  type: git
  source:
    uri: git@github.com:concourse/git-resource.git
    branch: master
    private_key: ((ssh.private_key))

jobs:
- name: my-project-resource
  public: true
  plan:
  - get: resource-tutorial
    trigger: true
```    

<h3 id="generating-secrets" data-source-line="126">
  <a class="anchor" href="#generating-secrets"><span class="octicon octicon-link"></span></a>Generating Secrets
</h3>

<p data-source-line="128">
  In addition to storing secrets, Credhub can be used to generate them.
</p>

<ul data-source-line="130">
  <li>
    Generate a new SSH key pair
  </li>
</ul>

```bash
credhub generate -t ssh --name /concourse/main/testssh  
```    

<ul data-source-line="136">
  <li>
    retrieve the public key
  </li>
</ul>

```bash
credhub get --name testssh2 --output-json | jq .value.public_key

```

</body></html>