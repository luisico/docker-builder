FROM docker:stable-git

RUN apk add --no-cache bash

COPY build_images.sh /usr/local/bin/build_images.sh
