#!/bin/bash
hugo -s ""
rsync -avz public/ ubuntu@ellin.com:/home/hugo-site