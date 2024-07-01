#!/bin/bash -ex

JOBS=8

FFMPEG_TAG=n4.2.1
LIBYUV_TAG=cbe5385055b9360cacd14877450631b87eea1fcd
LIBZVBI_TAG=e62d905e00cdd1d6d4333ead90fb5b44bfb49371
X265_TAG=Release_3.3
X265_TAG=ef1c5205fc14d436b71b1459eba0c85fec0013b7
X264_TIP=0
X264_BITDEPTH=8
JSONC_TAG=6c55f65d07a972dbd2d1668aab2e0056ccdd52fc
BUILD_X265=0
BUILD_LIBWEBSOCKETS=0
LIBWEBSOCKETS_TAG=v3.2.0
LIBLTNSDI_TAG=master
BUILD_LIBLTNSDI=1
BUILD_JSONC=0
BUILD_LIBAV=1
BUILD_VAAPI=0
BUILD_NVENC=0
BUILD_VEGA3301=0
BUILD_VEGA3311=0
VEGA_SDK=$PWD/vega-sdk
BUILD_LIBLTNTSTOOLS=0
LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
# Absolute path to the SDK. Fixme.
BUILD_NDI=0
NDI_SDK=$PWD/NDI/sdk
# Absolute path to the SDK. Fixme.
BUILD_DEKTEC=0
DEKTEC_DRV=$PWD/dektecsdk/2019.11.0/Drivers/DtPcie/Source/Linux
DEKTEC_SDK=$PWD/dektecsdk/2019.11.0/DTAPI
DEKTEC_SDK_INC=$PWD/dektecsdk/2019.11.0/DTAPI/Include

# https://github.com/libjpeg-turbo/libjpeg-turbo.git
# cd libjpeg-turbo
# mkdir build
# cd build
# cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=$PWD/../../target-root/usr/local ..
# make
# make install


if [ "$1" == "" ]; then
	# Fine if they do not specify a tag
	echo "No specific tag specified.  Using master"
	OBE_TAG=master
elif [ "$1" == "--tarball" ]; then
	# copy the current obe binary and any deps into something
	# that the LTN release manager can absorb.
	rm -f tarball.tgz
	mkdir -p ltn-tarball/ltn/ltn_encoder/bin
	cp obe-rt/obe/obecli ltn-tarball/ltn/ltn_encoder
	cp -r cfg ltn-tarball/ltn/ltn_encoder
	cp -r NDI/sdk/lib/x86_64-linux-gnu ltn-tarball/ltn/ltn_encoder/lib
	cp -r johnlane/ltn_confs ltn-tarball/ltn
	cp -r johnlane/services ltn-tarball/ltn
	cp -r johnlane/ltn_encoder/controller ltn-tarball/ltn/ltn_encoder
	cp -r johnlane/ltn_encoder/*.conf ltn-tarball/ltn/ltn_encoder
	cp -r johnlane/ltn_encoder/README ltn-tarball/ltn/ltn_encoder
	cp -r johnlane/ltn_encoder/CHANGELOG.md ltn-tarball/ltn/ltn_encoder
	cp -r johnlane/ltn_encoder/conf_templates ltn-tarball/ltn/ltn_encoder
	cp NDI/sdk/bin/x86_64-linux-gnu/ndi-record ltn-tarball/ltn/ltn_encoder/bin
	echo 'setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PWD/lib' >ltn-tarball/ltn/ltn_encoder/screenrc
	echo 'setenv NDI_CONFIG_DIR $PWD/cfg' >>ltn-tarball/ltn/ltn_encoder/screenrc
	tar -zcf tarball.tgz -C ltn-tarball .
	rm -rf ltn-tarball
	exit 0
elif [ "$1" == "--installdeps" ]; then

	if [ -f /.dockerenv ]; then
		# Docker centos7.8 needs this
		sudo yum -y install wget xz-devel
	fi

	# We need epel for YASM
	sudo yum -y install epel-release
	sudo yum -y install yum-utils

	# We can't use nasm 2.15 with centos 7.8 because the rpmlibs
	# are incompat. We have to build with nasm 2.14
	#sudo yum-config-manager --add-repo http://www.nasm.us/nasm.repo
	#sudo yum -y install nasm
	#sudo yum repolist

	RHAT_VERSION=`cat /etc/redhat-release`
	if [ "$RHAT_VERSION" == "CentOS Linux release 7.8.2003 (Core)" ]; then
		if [ ! -f nasm-2.14-0.fc27.x86_64.rpm ]; then
			wget https://www.nasm.us/pub/nasm/releasebuilds/2.14/linux/nasm-2.14-0.fc27.x86_64.rpm
		fi
		sudo rpm -i nasm-2.14-0.fc27.x86_64.rpm
	fi

	sudo yum -y install libtool
	sudo yum -y install libpng
	sudo yum -y install yasm
	sudo yum -y install cmake
	sudo yum -y install perl-CPAN
	sudo yum -y install perl-Digest-MD5
	sudo yum -y install zlib-devel
	sudo yum -y install bzip2-devel
	sudo yum -y install readline-devel
	sudo yum -y install ncurses-static
	sudo yum -y install readline-static
	sudo yum -y install alsa-lib-devel
	sudo yum -y install pulseaudio-libs-devel
	sudo yum -y install libpciaccess-devel
	#sudo perl -MCPAN -e 'install Digest::Perl::MD5'
	# 3.0.0
	sudo yum -y install openssl-devel
	# Satisfy OSX objC autotools rule on linux
	sudo yum -y install gcc-objc
	exit 0
elif [ "$1" == "experimental" ]; then
	OBE_TAG=experimental
elif [ "$1" == "customerd" ]; then
	OBE_TAG=customerd-0.1
	LIBKLVANC_TAG=customerd-0.1
	LIBKLSCTE35_TAG=customerd-0.1
elif [ "$1" == "104_refactoring" ]; then
	OBE_TAG=104_refactoring
	LIBKLVANC_TAG=104_refactoring
	LIBKLSCTE35_TAG=104_refactoring
elif [ "$1" == "vid.obe.1.1" ]; then
	OBE_TAG=vid.obe.1.1.20
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "vid.obe.2.0.11" ]; then
	OBE_TAG=vid.obe.2.0.11
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
elif [ "$1" == "vid.obe.2.0.12" ]; then
	OBE_TAG=vid.obe.2.0.12
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
elif [ "$1" == "vid.obe.2.0.14" ]; then
	OBE_TAG=vid.obe.2.0.14
	LIBKLVANC_TAG=vid.obe.1.2.1
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
elif [ "$1" == "vid.obe.2.0.15" ]; then
	OBE_TAG=vid.obe.2.0.15
	LIBKLVANC_TAG=vid.obe.1.2.1
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=5442a8600d6d1eeb44e3bafe2b9992c531cd39b2
	BUILD_X265=1
elif [ "$1" == "vid.obe.2.0.16" ]; then
	OBE_TAG=vid.obe.2.0.16
	LIBKLVANC_TAG=vid.obe.1.2.1
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
elif [ "$1" == "vid.obe.2.0.22" ]; then
	OBE_TAG=vid.obe.2.0.22
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
elif [ "$1" == "vid.obe.2.0" ]; then
	OBE_TAG=2.0.0
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
elif [ "$1" == "vid.obe.3.0.0" ]; then
	OBE_TAG=3.0.0
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
elif [ "$1" == "vid.obe.3.0.3" ]; then
	OBE_TAG=vid.obe.3.0.3
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
elif [ "$1" == "vid.obe.3.1.0" ]; then
	OBE_TAG=vid.obe.3.1.0
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
elif [ "$1" == "vid.obe.3.2.6" ]; then
	OBE_TAG=vid.obe.3.2.6
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
elif [ "$1" == "vid.obe.3.2.7" ]; then
	OBE_TAG=vid.obe.3.2.7
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
elif [ "$1" == "vid.obe.3.2.8" ]; then
	OBE_TAG=vid.obe.3.2.8
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
elif [ "$1" == "vid.obe.3.2.9" ]; then
	OBE_TAG=vid.obe.3.2.9
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.2
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
elif [ "$1" == "vid.obe.3.3.0" ]; then
	OBE_TAG=vid.obe.3.3.0
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
elif [ "$1" == "vid.obe.3.4.0" ]; then
	OBE_TAG=vid.obe.3.4.0
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.2.0
	LIBMPEGTS_TAG=hevc-dev-0.1
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.5.0" ]; then
	OBE_TAG=vid.obe.3.5.0
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=0
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.6.2" ]; then
	OBE_TAG=vid.obe.3.6.2
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=0
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.7.1" ]; then
	OBE_TAG=vid.obe.3.7.1
	LIBKLVANC_TAG=vid.obe.1.2.2
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=0
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.8.0" ]; then
	OBE_TAG=vid.obe.3.8.0
	LIBKLVANC_TAG=vid.obe.1.3.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=0
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.9.0" ]; then
	OBE_TAG=vid.obe.3.9.0
	LIBKLVANC_TAG=vid.obe.1.3.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=0
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.10.0" ]; then
	OBE_TAG=vid.obe.3.10.0
	LIBKLVANC_TAG=vid.obe.1.5.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=0
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.11.0" ]; then
	OBE_TAG=vid.obe.3.11.0
	LIBKLVANC_TAG=vid.obe.1.5.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.12.1" ]; then
	OBE_TAG=vid.obe.3.12.1
	LIBKLVANC_TAG=vid.obe.1.5.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.3.14.1" ]; then
	OBE_TAG=vid.obe.3.14.1
	LIBKLVANC_TAG=vid.obe.1.5.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.4.0.1" ]; then
	OBE_TAG=vid.obe.4.0.1
	LIBKLVANC_TAG=vid.obe.1.8.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.0.2" ]; then
	OBE_TAG=vid.obe.4.0.2
	LIBKLVANC_TAG=vid.obe.1.8.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.0.3" ]; then
	OBE_TAG=vid.obe.4.0.3
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.0.5" ]; then
	OBE_TAG=vid.obe.4.0.5
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.1.0" ]; then
	OBE_TAG=vid.obe.4.1.0
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.1.4" ]; then
	OBE_TAG=vid.obe.4.1.4
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.1.5" ]; then
	OBE_TAG=vid.obe.4.1.5
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.0.0" ]; then
	OBE_TAG=3.0.0
	LIBKLVANC_TAG=vid.obe.1.8.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.3.0-dev" ]; then
	OBE_TAG=3.0.0
	LIBKLVANC_TAG=vid.obe.1.5.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
elif [ "$1" == "vid.obe.1.1.12" ]; then
	OBE_TAG=vid.obe.1.1.12
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "vid.obe.1.1.14" ]; then
	OBE_TAG=vid.obe.1.1.14
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "vid.obe.1.1.15" ]; then
	OBE_TAG=vid.obe.1.1.15
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "vid.obe.1.1.16" ]; then
	OBE_TAG=vid.obe.1.1.16
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "vid.obe.1.1.18" ]; then
	OBE_TAG=vid.obe.1.1.18
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "1.1.21" ]; then
	OBE_TAG=1.1.21
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=hevc-dev-0.1
elif [ "$1" == "vid.obe.4.2.0-dev" ]; then
	OBE_TAG=3.0.0
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
elif [ "$1" == "vid.obe.4.2.1" ]; then
	OBE_TAG=vid.obe.4.2.1
	LIBKLVANC_TAG=vid.obe.1.10.0
	LIBKLSCTE35_TAG=vid.obe.1.3.0
	LIBMPEGTS_TAG=hevc-dev
	BUILD_X265=1
	BUILD_LIBAV=0
	BUILD_VAAPI=0
	BUILD_LIBWEBSOCKETS=0
	BUILD_JSONC=0
	BUILD_LIBLTNTSTOOLS=1
	LIBLTNTSTOOLS_TAG=4fbb32125bc1ea095cf26a0f7b1b279082fdd592
	BUILD_NDI=1
	BUILD_DEKTEC=0
	BUILD_VEGA3311=1
else
	echo "Invalid argument"
	exit 1
fi
BMSDK_REPO=https://github.com/LTNGlobal-opensource/bmsdk.git

if [ ! -d bmsdk ]; then
    git clone $BMSDK_REPO
fi
if [ `uname -s` = "Darwin" ]; then
    PLAT=Mac
else
    PLAT=Linux
fi
BMSDK_10_11_2=$PWD/bmsdk/10.11.2/$PLAT
BMSDK_10_8_5=$PWD/bmsdk/10.8.5/$PLAT
BMSDK_10_1_1=$PWD/bmsdk/10.1.1/$PLAT
BMSDK_12_9=$PWD/bmsdk/12.9/$PLAT

if [ $BUILD_LIBLTNSDI -eq 1 ]; then
	if [ ! -d libltnsdi ]; then
		git clone https://github.com/LTNGlobal-opensource/libltnsdi
		cd libltnsdi && git checkout $LIBLTNSDI_TAG && cd ..
	fi
fi

if [ $BUILD_LIBLTNTSTOOLS -eq 1 ]; then
	if [ ! -d libltntstools ]; then
		git clone https://github.com/LTNGlobal-opensource/libltntstools
		cd libltntstools && git checkout $LIBLTNTSTOOLS_TAG && cd ..
	fi
fi

if [ $BUILD_JSONC -eq 1 ]; then
	if [ ! -d json-c ]; then
		git clone https://github.com/json-c/json-c.git
		cd json-c && git checkout $JSONC_TAG && cd ..
	fi
fi

if [ $BUILD_LIBWEBSOCKETS -eq 1 ]; then
	if [ ! -d libwebsockets ]; then
		git clone https://libwebsockets.org/repo/libwebsockets
		cd libwebsockets && git checkout $LIBWEBSOCKETS_TAG && cd ..
	fi
fi

if [ $BUILD_NDI -eq 1 ]; then
	mkdir -p NDI
	cd NDI
	if [ ! -f InstallNDISDK_v4_Linux.tar.gz ]; then
		wget --no-check-certificate https://downloads.ndi.tv/SDK/NDI_SDK_Linux/InstallNDISDK_v4_Linux.tar.gz
	fi
	if [ ! -f InstallNDISDK_v4_Linux.sh ]; then
		tar zxf InstallNDISDK_v4_Linux.tar.gz
	fi
	if [ ! -d sdk ]; then
		echo "Y" | ./InstallNDISDK_v4_Linux.sh >/dev/null
		mv 'NDI SDK for Linux' sdk
	fi
	cd ..
fi

if [ $BUILD_DEKTEC -eq 1 ]; then
	mkdir -p dektecsdk
	if [ ! -f dektecsdk/LinuxSDK_v2019.11.0.tar.gz ]; then
		cd dektecsdk
		wget https://www.dektec.com/products/applications/DtRecord/Downloads/DtRecord_v4.9.0.zip
		wget https://www.dektec.com/products/SDK/DTAPI/Downloads/LinuxSDK_v2019.11.0.tar.gz
		wget https://www.dektec.com/products/applications/DtInfoCL/downloads/DtInfoCL.zip
		wget https://www.dektec.com/products/sdk/MatrixApi/downloads/MatrixExamples.zip
		tar zxf LinuxSDK_v2019.11.0.tar.gz
		mv LinuxSDK 2019.11.0
		cd ..
	fi
fi

if [ $BUILD_X265 -eq 1 ]; then
	if [ ! -d x265 ]; then
		git clone https://github.com/videolan/x265.git
		cd x265
		git checkout $X265_TAG
		patch -p1 <../0003-x265-sei-overflow.patch
		patch -p1 <../0004-x265-sei-additional-elements-segfault.patch
		#patch -p1 <../0005-x265-additional-recovery-points.patch
		cd ..
	fi
fi

if [ ! -d libzvbi ]; then
	git clone https://github.com/LTNGlobal-opensource/libzvbi.git
	if [ "$LIBZVBI_TAG" != "" ]; then
		cd libzvbi
		git checkout $LIBZVBI_TAG
		patch -p1 <../0000-libzvbi-remove-png-dep.patch
		cd ..
	fi
fi

if [ ! -d libklvanc ]; then
	git clone https://github.com/LTNGlobal-opensource/libklvanc.git
	if [ "$LIBKLVANC_TAG" != "" ]; then
		cd libklvanc && git checkout $LIBKLVANC_TAG && cd ..
	fi
fi

if [ ! -d libklscte35 ]; then
	git clone https://github.com/LTNGlobal-opensource/libklscte35.git
	if [ "$LIBKLSCTE35_TAG" != "" ]; then
		cd libklscte35 && git checkout $LIBKLSCTE35_TAG && cd ..
	fi
fi

if [ ! -d obe-rt ]; then
	git clone https://github.com/LTNGlobal-opensource/obe-rt.git
	if [ "$OBE_TAG" != "" ]; then
		cd obe-rt && git checkout $OBE_TAG && cd ..
	fi
fi

if [ "$X264_TIP" -eq 1 ]; then
	if [ ! -d x264 ]; then
		git clone https://code.videolan.org/videolan/x264.git
	fi
else
	if [ ! -d x264-obe ]; then
		git clone https://github.com/LTNGlobal-opensource/x264-obe.git
		cd x264-obe
		patch -p1 <../pic0001.diff
		patch -p1 <../pic0002.diff
		patch -p1 <../pic0003.diff
		patch -p1 <../pic0004.diff
		cd ..
	fi
fi

if [ ! -d fdk-aac ]; then
	git clone https://github.com/LTNGlobal-opensource/fdk-aac.git
fi

if [ $BUILD_LIBAV -eq 1 ]; then
	if [ ! -d libav-obe ]; then
		git clone https://github.com/LTNGlobal-opensource/libav-obe.git
	fi
else
	if [ ! -d ffmpeg ]; then
		git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
		cd ffmpeg && git checkout $FFMPEG_TAG && cd ..
	fi
fi

if [ ! -d libmpegts-obe ]; then
	git clone https://github.com/LTNGlobal-opensource/libmpegts-obe.git
	if [ "$LIBMPEGTS_TAG" != "" ]; then
		cd libmpegts-obe && git checkout $LIBMPEGTS_TAG && cd ..
	fi
fi

if [ ! -d libyuv ]; then
	git clone https://github.com/LTNGlobal-opensource/libyuv.git
	pushd libyuv
		# Make sure we use a known-good version
		git checkout $LIBYUV_TAG
		patch -p1 <../0002-libyuv-csc-height.patch
	popd
fi

if [ ! -d twolame-0.3.13 ]; then
	tar zxf twolame-0.3.13.tar.gz
fi

if [ $BUILD_VEGA3311 -eq 1 ]; then
	if [ ! -d $VEGA_SDK ]; then
		if [ ! -f vega-sdk-ltn-0.0.0.tgz ]; then
			echo "VEGA SDK required to build the product. vega-sdk-ltn-0.0.0.tgz missing, aborting."
			exit 1
		fi

		tar zxf vega-sdk-ltn-0.0.0.tgz
	fi
fi

if [ $BUILD_DEKTEC -eq 1 ]; then
	pushd $DEKTEC_DRV
		make
		sudo insmod ./DtPcie.ko
		if [ ! -d /dev/DtPcie0 ]; then
			echo "Dektec module load failed, aborting."
			exit 1
		fi
	popd
fi


if [ $BUILD_LIBLTNSDI -eq 1 ]; then
	pushd libltnsdi
		if [ ! -f .skip ]; then
			./autogen.sh --build
			./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
			make -j$JOBS
			make install
			touch .skip
		fi
	popd
fi

if [ $BUILD_LIBLTNTSTOOLS -eq 1 ]; then
	pushd libltntstools
		if [ ! -f .skip ]; then
			./autogen.sh --build
			./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
			make -j$JOBS
			make install
			touch .skip
		fi
	popd
fi

if [ $BUILD_VAAPI -eq 1 ]; then
	pushd vaapi
		./build.sh
		# Newer builds default to the iHD driver, use the haswell compatible driver.
		# LIBVA_DRIVER_NAME=i965 ./vainfo
	popd
fi

if [ $BUILD_NVENC -eq 1 ]; then
	# References:
	# https://linuxconfig.org/how-to-install-nvidia-cuda-toolkit-on-centos-7-linux
	# https://arstech.net/compile-ffmpeg-with-nvenc-h264/
	# TODO
	# Blacklist the nouveau driver
	# Install the proprietary NVidia driver
	# $ wget https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.0.130-1.x86_64.rpm
	# $ sudo rpm -i cuda-repo-rhel7-10.0.130-1.x86_64.rpm
	# Install cuda and A LOT of deps
	# $ sudo yum -i install cuda
	:
fi

if [ $BUILD_JSONC -eq 1 ]; then
	pushd json-c
		if [ ! -f .skip ]; then
			./autogen.sh
			./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
			make -j$JOBS
			make install
			touch .skip
		fi
	popd
fi

if [ $BUILD_LIBWEBSOCKETS -eq 1 ]; then
	pushd libwebsockets
		if [ ! -f .skip ]; then
			mkdir -p build
			cd build
			cmake -DCMAKE_INSTALL_PREFIX:PATH=$PWD/../../target-root/usr/local ..
			make -j$JOBS
			make install
			cd ..
			touch .skip
		fi
	popd
fi

if [ $BUILD_X265 -eq 1 ]; then
	pushd x265/build/linux
		if [ ! -f .skip ]; then
			# Static only build
			#./make-Makefiles.bash
			cmake -DCMAKE_INSTALL_PREFIX=$PWD/../../../target-root/usr/local \
				-G "Unix Makefiles" \
				-DENABLE_SHARED:bool=off \
				../../source
			make -j$JOBS
			make install
			#touch .skip
		fi
	popd
fi

pushd libzvbi
	if [ ! -f .skip ]; then
		./configure --enable-shared=no --prefix=$PWD/../target-root/usr/local
		make && make install
		make install
		touch .skip
	fi
popd

pushd libklvanc
	if [ ! -f .skip ]; then
		./autogen.sh --build
		./configure --enable-shared=no --prefix=$PWD/../target-root/usr/local --enable-dep-curses=no
		make && make install
		make install
		touch .skip
	fi
popd

pushd libklscte35
	if [ ! -f .skip ]; then
		./autogen.sh --build
		export CFLAGS="-I$PWD/../target-root/usr/local/include"
		export LDFLAGS="-L$PWD/../target-root/usr/local/lib"
		./configure --enable-shared=no --prefix=$PWD/../target-root/usr/local
		make && make install
		touch .skip
	fi
popd

pushd libmpegts-obe
	if [ ! -f .skip ]; then
		./configure --prefix=$PWD/../target-root/usr/local
		make && make install
		make install
		touch .skip
	fi
popd

pushd twolame-0.3.13
	if [ ! -f .skip ]; then
		./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
		make && make install
		touch .skip
	fi
popd

if [ "$X264_TIP" -eq 1 ]; then
	pushd x264
		if [ ! -f .skip ]; then
			make clean
			./configure --enable-static --prefix=$PWD/../target-root/usr/local --disable-lavf --disable-swscale --disable-opencl --bit-depth=$X264_BITDEPTH
			make -j$JOBS && make install
			touch .skip
		fi
	popd
else
	pushd x264-obe
		if [ ! -f .skip ]; then
			make clean
			./configure --enable-static --disable-cli --prefix=$PWD/../target-root/usr/local --disable-lavf --disable-swscale --disable-opencl --bit-depth=$X264_BITDEPTH
			make -j$JOBS && make install
			touch .skip
		fi
	popd
fi

pushd fdk-aac
	if [ ! -f .skip ]; then
		./autogen.sh
		./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
		make && make install
		touch .skip
	fi
popd

if [ $BUILD_LIBAV -eq 1 ]; then
	pushd libav-obe
		if [ ! -f .skip ]; then
			./configure --prefix=$PWD/../target-root/usr/local --enable-libfdk-aac --enable-gpl --enable-nonfree \
				--disable-swscale-alpha --disable-avdevice \
				--extra-ldflags="-L$PWD/../target-root/usr/local/lib" \
				--extra-cflags="-I$PWD/../target-root/usr/local/include -ldl"
			make -j$JOBS && make install
			touch .skip
		fi
	popd
else
	pushd ffmpeg
	if [ ! -f .skip ]; then
		export CFLAGS="-I$PWD/../target-root/usr/local/include -I$BMSDK_10_11_2/include"
		export LDFLAGS="-L$PWD/../target-root/usr/local/lib -lpthread -ldl"
		export PKG_CONFIG_PATH=$PWD/../target-root/usr/local/lib/pkgconfig:/usr/local/lib/pkgconfig
		./configure --prefix=$PWD/../target-root/usr/local \
			--enable-gpl \
			--enable-nonfree \
			--enable-decklink \
			--enable-libfdk-aac \
			--disable-swscale-alpha \
			--enable-libfdk-aac \
			--enable-libx264 \
			--pkg-config-flags="--static" \
			--enable-libx265 \
			--enable-gpl \
			--enable-nonfree

# For NVENC and Cuda
#			--enable-cuda-nvcc --enable-cuvid --enable-nvenc \
#			--extra-cflags="-I/usr/local/cuda/include/" \
#			--extra-ldflags=-L/usr/local/cuda/lib64/

		make -j$JOBS && make install
		unset CFLAGS
		unset LDFLAGS
		unset PKG_CONFIG_PATH
		touch .skip
	fi
	popd
fi

pushd libyuv
	if [ ! -f .skip ]; then
		make -f linux.mk
		cp -r include/* $PWD/../target-root/usr/local/include
		cp libyuv.a $PWD/../target-root/usr/local/lib
		touch .skip
	fi
popd

build_obe() {
    GITVER=`echo $1 | sed 's/^vid.obe.//'`
    BMSDK_DIR=$2
    BMVERSION=`cat $BMSDK_DIR/include/DeckLinkAPIVersion.h | grep BLACKMAGIC_DECKLINK_API_VERSION_STRING | awk '{print $3}'|sed -e 's/^"//' -e 's/"$//'`

    echo "Building OBE $GITVER for BlackMagic SDK version $BMVERSION"

    if [ "$1" == "customerd" ]; then
	pushd obe-rt
	export CXXFLAGS="-I$PWD/../target-root/usr/local/include -ldl"
	export PKG_CONFIG_PATH=$PWD/../target-root/usr/local/lib/pkgconfig
	./configure \
		--extra-ldflags="-L$PWD/../target-root/usr/local/lib -lfdk-aac -lavutil -lasound -lyuv -lklvanc" \
		--extra-cflags="-I$PWD/../target-root/usr/local/include -ldl" \
		--extra-cxxflags="-I$BMSDK_DIR"
	make clean
	make
	DESTDIR=$PWD/../target-root make install
	popd
    else
	pushd obe-rt
	export CFLAGS="-I$PWD/../target-root/usr/local/include -I$BMSDK_DIR"
	export LDFLAGS="-L$PWD/../target-root/usr/local/lib"
	export PKG_CONFIG_PATH=$PWD/../target-root/usr/local/lib/pkgconfig
	if [ $BUILD_NDI -eq 1 ]; then
		export CFLAGS="$CFLAGS -I$NDI_SDK/include"
		export LDFLAGS="$LDFLAGS -L$NDI_SDK/lib/x86_64-linux-gnu"
	fi
	if [ $BUILD_VEGA3311 -eq 1 ]; then
		export CFLAGS="$CFLAGS -I$VEGA_SDK/vega3311/include/libvega_capture_api"
		export CFLAGS="$CFLAGS -I$VEGA_SDK/vega3311/include/libvega_bqb_api"
		export CFLAGS="$CFLAGS -I$VEGA_SDK/vega3311/include/libvega_transmit_api"
		export LDFLAGS="$LDFLAGS -L$VEGA_SDK/vega3311/lib"
	fi
	if [ $BUILD_VEGA3301 -eq 1 ]; then
		export CFLAGS="$CFLAGS -I$VEGA_SDK/vega3301/include/libvega_capture_api"
		export CFLAGS="$CFLAGS -I$VEGA_SDK/vega3301/include/libvega_encoder_api"
		export CFLAGS="$CFLAGS -I$VEGA_SDK/vega3301/include/libvega_bqb_api"
		export LDFLAGS="$LDFLAGS -L$VEGA_SDK/vega3301/lib"
	fi
	if [ $BUILD_DEKTEC -eq 1 ]; then
		export CFLAGS="$CFLAGS -I$DEKTEC_SDK_INC"
		export CPPFLAGS=$CFLAGS
	fi

	if [ -f autogen.sh ]; then
		./autogen.sh --build
	fi
	./configure --prefix=$PWD/../target-root/usr/local
	make clean
	make -j$JOBS
	make install
	popd
	cp target-root/usr/local/bin/obecli obecli-$GITVER-bm$BMVERSION
    fi
}

#build_obe $OBE_TAG $BMSDK_10_1_1
build_obe $OBE_TAG $BMSDK_12_9
build_obe $OBE_TAG $BMSDK_10_8_5
