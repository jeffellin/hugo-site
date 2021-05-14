#!/bin/bash
hugo -s ""
#rsync -avz public/ ubuntu@ellin.com:/home/hugo-site
aws s3 sync public s3://ellin-com
