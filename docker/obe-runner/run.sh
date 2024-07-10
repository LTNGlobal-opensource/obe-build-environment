#!/bin/bash

rm -rf app
mkdir app

cp ../../obe-rt/obe/obecli app
cp ../../obe-rt/cfgs/avc-ll-20mb-2xmp2.cfg app/encoder.cfg
cp /lib64/libasound.so.2 app
cp /lib64/libncurses.so.5 app
cp /lib64/libtinfo.so.5 app
cp /usr/lib64/libDeckLinkAPI.so app

docker run -it \
	--name encoder0 \
	--rm \
	-e LD_LIBRARY_PATH='/app:/usr/lib64/blackmagic/DesktopVideo' \
	-v $PWD/app:/app \
	-v /dev/blackmagic:/dev/blackmagic \
	-v /etc/blackmagic:/etc/blackmagic \
	-v /usr/lib64/blackmagic:/usr/lib64/blackmagic \
	-w '/app' \
	--privileged \
	--network=host centos /app/obecli -c encoder.cfg

# ctrl-p then ctrl-q to detach from the runtime.
# docker attach encoder0
