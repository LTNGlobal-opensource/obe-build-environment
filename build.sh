#!/bin/bash -ex

JOBS=8

#yum install yasm
#yum install perl-CPAN
#yum install perl-Digest-MD5
#yum install libz-devel 
#yum install bzip2-devel
#yum install readline-devel
#yum install zvbi-devel
#yum install ncurses-static
#yum install readline-static
#yum install alsa-lib-devel
#yum install pulseaudio-libs-devel
#perl -MCPAN -e 'install Digest::Perl::MD5'

if [ "$1" == "" ]; then
	# Fine if they do not specify a tag
	echo "No specific tag specified.  Using master"
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
	OBE_TAG=vid.obe.1.1.11
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "vid.obe.1.1.12" ]; then
	OBE_TAG=vid.obe.1.1.12
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "52workaround" ]; then
	OBE_TAG=52workaround
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "audio-offset" ]; then
	OBE_TAG=audio-offset
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "syslog-string" ]; then
	OBE_TAG=syslog-string
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "ac3crc" ]; then
	OBE_TAG=ac3crc
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "1080p60" ]; then
	OBE_TAG=1080p60
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "shortaudio" ]; then
	OBE_TAG=shortaudio
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "ac3disconnect" ]; then
	OBE_TAG=ac3disconnect
	LIBKLVANC_TAG=vid.obe.1.1.5
	LIBKLSCTE35_TAG=vid.obe.1.1.2
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
elif [ "$1" == "klvanc-new-namespace" ]; then
	OBE_TAG=klvanc-new-namespace
	LIBKLVANC_TAG=master
	LIBKLSCTE35_TAG=master
	LIBMPEGTS_TAG=vid.libmpegts-obe-1.1.2
else
	echo "Invalid argument"
	exit 1
fi

if [ ! -d bmsdk ]; then
	git clone https://github.com/LTNGlobal-opensource/bmsdk.git
	ln -fs 'bmsdk/Blackmagic DeckLink SDK 10.8.5' decklink-sdk
fi

if [ ! -d libklvanc ]; then
	#git clone https://github.com/LTNGlobal-opensource/libklvanc.git
	git clone https://github.com/stoth68000/libklvanc.git
	if [ "$LIBKLVANC_TAG" != "" ]; then
		cd libklvanc && git checkout $LIBKLVANC_TAG && cd ..
	fi
fi

if [ ! -d klvanc-tools ]; then
	git clone https://github.com/stoth68000/klvanc-tools.git
fi

if [ ! -d libklscte35 ]; then
	#git clone https://github.com/LTNGlobal-opensource/libklscte35.git
	git clone https://github.com/stoth68000/libklscte35.git
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

if [ ! -d x264-obe ]; then
	git clone https://github.com/LTNGlobal-opensource/x264-obe.git
fi

if [ ! -d fdk-aac ]; then
	git clone https://github.com/LTNGlobal-opensource/fdk-aac.git
fi

if [ ! -d libav-obe ]; then
	git clone https://github.com/LTNGlobal-opensource/libav-obe.git
fi

if [ ! -d libmpegts-obe ]; then
	git clone https://github.com/LTNGlobal-opensource/libmpegts-obe.git
	if [ "$LIBMPEGTS_TAG" != "" ]; then
		cd libmpegts-obe && git checkout $LIBMPEGTS_TAG && cd ..
	fi
fi

if [ ! -d libyuv ]; then
	git clone https://github.com/LTNGlobal-opensource/libyuv.git
fi

if [ ! -d twolame-0.3.13 ]; then
	tar zxf twolame-0.3.13.tar.gz
fi

pushd libklvanc
	./autogen.sh --build
	./configure --enable-shared=no --prefix=$PWD/../target-root/usr/local
	make && make install
	make install
popd

pushd klvanc-tools
	./autogen.sh --build
	export CFLAGS="-I$PWD/../target-root/usr/local/include"
	export LDFLAGS="-L$PWD/../target-root/usr/local/lib"
	./configure --enable-shared=no --prefix=$PWD/../target-root/usr/local
	make && make install
	make install
popd

pushd libklscte35
	./autogen.sh --build
	export CFLAGS="-I$PWD/../target-root/usr/local/include"
	export LDFLAGS="-L$PWD/../target-root/usr/local/lib"
	./configure --enable-shared=no --prefix=$PWD/../target-root/usr/local
	make && make install
popd

pushd libmpegts-obe
	./configure --prefix=$PWD/../target-root/usr/local
	make && make install
	make install
popd

pushd twolame-0.3.13
	./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
	make && make install
popd

pushd x264-obe
	make clean
	./configure --enable-static --disable-cli --prefix=$PWD/../target-root/usr/local --disable-lavf --disable-swscale --disable-opencl
	make -j$JOBS && make install
popd

pushd fdk-aac
	./autogen.sh
	./configure --prefix=$PWD/../target-root/usr/local --enable-shared=no
	make && make install
popd

pushd libav-obe
	./configure --prefix=$PWD/../target-root/usr/local --enable-libfdk-aac --enable-gpl --enable-nonfree \
		--disable-swscale-alpha --disable-avdevice \
		--extra-ldflags="-L$PWD/../target-root/usr/local/lib" \
		--extra-cflags="-I$PWD/../target-root/usr/local/include -ldl"
	make -j$JOBS && make install
popd

pushd libyuv
	# Make sure we use a known-good version
	git checkout cbe5385055b9360cacd14877450631b87eea1fcd
	make -f linux.mk
	cp -r include/* $PWD/../target-root/usr/local/include
	cp libyuv.a $PWD/../target-root/usr/local/lib
popd

if [ "$1" == "customerd" ]; then
	pushd obe-rt
		export CXXFLAGS="-I$PWD/../target-root/usr/local/include -ldl"
		export PKG_CONFIG_PATH=$PWD/../target-root/usr/local/lib/pkgconfig
		./configure \
			--extra-ldflags="-L$PWD/../target-root/usr/local/lib -lfdk-aac -lavutil -lasound -lyuv -lklvanc" \
			--extra-cflags="-I$PWD/../target-root/usr/local/include -ldl" \
			--extra-cxxflags="-I$PWD/../decklink-sdk/Linux"
		make
		DESTDIR=$PWD/../target-root make install
	popd
else
	pushd obe-rt
		export CFLAGS="-I$PWD/../target-root/usr/local/include -I$PWD/../decklink-sdk/Linux"
		export LDFLAGS="-L$PWD/../target-root/usr/local/lib"
		export PKG_CONFIG_PATH=$PWD/../target-root/usr/local/lib/pkgconfig
		if [ -f autogen.sh ]; then
			./autogen.sh --build
		fi
		./configure --prefix=$PWD/../target-root/usr/local
		make -j$JOBS
		make install
	popd
fi

