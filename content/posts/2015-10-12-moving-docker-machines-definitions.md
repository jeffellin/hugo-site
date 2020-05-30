---
id: 135
title: Moving Docker Machines Definitions
date: 2015-10-12T18:00:59+00:00
author: ellinj
layout: post

permalink: /2015/10/12/moving-docker-machines-definitions/
geo_public:
  - "0"
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=6059461587591315458&type=U&a=fSgX'
tags:
  - docker
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


[Docker Machine](https://docs.docker.com/machine/) is a new tool from Docker that allows you quickly create Docker hosts on your local machine or a cloud provider such as EC2 or Google Compute.  During the machine creation process the docker machine library creates a new ssh key and ssl certificate to interact with this machine via the docker client tools.

This is all great and allows a developer to quickly create a new cloud instance in minutes.  However if you want to share the docker machine with coworker things become a little murky.

The easiest way to grant a coworker access to the machine is to pass them the id_rsa file which contains the ssh key.  You can then access the host via the following command.

[code lang=text]  
ssh -i id_rsa <user>@<host>

[/code]

once logged into the machine you can use regular docker commands as normal. Although typically sudo will be required.  The key is usually located in ~/.docker/machine/machines/<machine_name>

[code lang=text]  
sudo docker ps

[/code]

This generally works in most cases but if you want your coworkers to be able to access the machine using docker-machine, some manually manipulation of the config.json file is required.

<span style="color:#ff0000;">The following tested with Docker-Machine config files version 1.  Make a backup copy before testing this out.</span>

  1. Copy the contents of ~/.docker/machine/machines/<machinename> to the target pc.
  2. Update the following sections of config.json. In most cases just updating the home directory is all that is needed. 
      * <p class="p1">
          <span class="s1">Driver.CaCertPath  &#8211; the CA cert should point to the ca cert in the machine directory rather then the one in the certs directory.<br /> </span>
        </p>
        
        <p class="p1">
          <span class="s1">/Users/jellin/.docker/machine/machines/dev/ca.pem,</span>
        </p>
    
      * <p class="p1">
          <span class="s1">AuthOptions.ServerCertPath &#8211; Update to the Cert in the machine directory</span>
        </p>
    
      * <p class="p1">
          AuthOptions.ServerKeyPath &#8211; Update to the Key in the machine directory
        </p>
    
      * <p class="p1">
          <span class="s1">AuthOptions.ClientKeyPath &#8211; </span><span style="line-height:1.5;">the </span><span style="line-height:1.5;">client key</span><span style="line-height:1.5;"> should point to the </span><span style="line-height:1.5;">client</span><span style="line-height:1.5;"> </span><span style="line-height:1.5;">key</span><span style="line-height:1.5;"> in the machine directory rather then the one in the certs directory.</span>
        </p>
        
        <p class="p1">
          <span class="s1">/Users/jellin/.docker/machine/machines/dev/key.pem,</span>
        </p>
    
      * <p class="p1">
          <span class="s1">AuthOptions.ClientCertPath &#8211;</span>
        </p>
        
        <p class="p1">
          <span class="s1"> the Client cert should point to the caclientcert in the machine directory rather then the one in the certs directory.<br /> </span>
        </p>
        
        <p class="p1">
          <span class="s1">/Users/jellin/.docker/machine/machines/dev/cert.pem,</span>
        </p>
    
      * StorePath &#8211; Update to the directory of the machine
  3. In the case of EC2,  the IAM credentials used to create the instance are also present.  You may wish to remove these as well before passing the key onto your colleague. 
      * Driver.AccessKey
      * Driver.SecretKey

Hopefully in the future the docker machine people will come up with a more portable way to share your machine creations.