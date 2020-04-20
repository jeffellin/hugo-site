#!/bin/bash
hugo -Ds ""
rsync -avz public/ ubuntu@ellin.com:/home/hugo-site