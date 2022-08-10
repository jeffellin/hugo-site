#!/bin/bash
hugo -s ""
#rsync -avz public/ ubuntu@ellin.com:/home/hugo-site
aws s3 sync public s3://ellin-com
 aws cloudfront  create-invalidation  --distribution-id E2J5TSOY7Z59TF --paths  "/*" --no-paginate
