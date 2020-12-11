+++
title = "Kubernetes on Ubuntu 20.04"
date = 2020-07-14T00:35:15-04:00
tags = ["spring","config"]
category = ["tech"]
featured_image = ""
description = "Kubernetes on Ubuntu 20.04"
draft = "true"
+++


Gnerate CSR

https://vcenter7.ellin.net/ui/app/admin/certificates




create a file called key.txt

view cert  openssl x509 -in vcenter.crt -noout -text

sign the cert

openssl x509 -req -in vcenter.csr -CA rootCA.pem -CAkey rootCA-key.pem -CAcreateserial -out vcenter.crt -sha256 -extfile v3.ext


put the following in v3.ext

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 =vcenter7.ellin.net



also,  edit openssl.cnf.  ( Not sure if this is necessary)  - Tested cert generates ok without it but I haven't imported it yet.

# Extension copying option: use with caution.
copy_extensions = copy


https://www.terataki.net/2020/04/14/add-custom-certificate-to-vcenter-7/