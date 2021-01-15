+++
title = "Kubernetes on Ubuntu 20.04"
date = 2020-07-14T00:35:15-04:00
tags = ["vcenter","vmware"]
category = ["tech"]
featured_image = ""
description = "Generating a cert for vcenter7"
draft = "false"
+++


1. Gnerate CSR

   https://vcenter7.ellin.net/ui/app/admin/certificates



2. Sign the CSR

    openssl x509 -req -in vcenter7.ellin.net.csr -CA rootCA.pem -CAkey rootCA-key.pem -CAcreateserial -out vcenter.crt -sha256 -extfile v3.ext -days 365

    Set the desired number of days.


3. put the following in v3.ext
```
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = vcenter7.ellin.net
    DNS.2 = vcenter7
    DNS.3 = 192.168.1.72

```
