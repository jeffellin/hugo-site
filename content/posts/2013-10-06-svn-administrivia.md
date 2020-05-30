---
id: 25
title: SVN Administrivia
date: 2013-10-06T01:45:27+00:00
author: ellinj
layout: post

permalink: /2013/10/06/svn-administrivia/
original_post_id:
  - "21"
tags:
  - Source Control
tags:
  - scm
  - svn
  - unix
---

Sometimes I find myself needing to remove all the hidden .svn directories. Here is the command if you are a Mac/*nix machine. 

<pre>find . -type d -name .svn -exec rm -rf {} ;
</pre>

If you do an svn export instead of a checkout you can also avoid the .svn housekeeping directories.