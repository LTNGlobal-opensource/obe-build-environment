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

EXPERIMENTAL=0
if [ "$1" == "experimental" ]; then
	EXPERIMENTAL=1
fi

if [ ! -d libklvanc ]; then
	git clone https://github.com/stoth68000/libklvanc.git
fi

if [ ! -d libklscte35 ]; then
	git clone https://github.com/stoth68000/libklscte35.git
fi

if [ ! -d obe-rt ]; then
	git clone https://github.com/stoth68000/obe-rt.git
	if [ $EXPERIMENTAL -eq 1 ]; then
		cd obe-rt && git checkout experimental && cd ..
	fi
fi

if [ ! -d x264-obe ]; then
	git clone https://github.com/stoth68000/x264-obe.git
fi

if [ ! -d fdk-aac ]; then
	git clone https://github.com/stoth68000/fdk-aac.git
fi

if [ ! -d libav-obe ]; then
	git clone https://github.com/stoth68000/libav-obe.git
fi

if [ ! -d libmpegts-obe ]; then
	git clone https://github.com/stoth68000/libmpegts-obe.git
fi

if [ ! -d libyuv ]; then
	git clone https://chromium.googlesource.com/libyuv/libyuv
fi

if [ ! -d obe-bitstream ]; then
	git clone https://github.com/stoth68000/obe-bitstream.git
fi

if [ ! -d twolame-0.3.13 ]; then
	tar zxf twolame-0.3.13.tar.gz
fi

if [ ! -d "Blackmagic DeckLink SDK 10.6.5" ]; then
	unzip Blackmagic_DeckLink_SDK_10.6.5.zip
	ln -fs 'Blackmagic DeckLink SDK 10.6.5' decklink-sdk
fi


pushd obe-bitstream
	make PREFIX=$PWD/../target-root/usr/local install
popd

pushd libklvanc
	./autogen.sh --build
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
	make -f linux.mk
	cp -r include/* $PWD/../target-root/usr/local/include
	cp libyuv.a $PWD/../target-root/usr/local/lib
popd

pushd obe-bitstream
	make PREFIX=$PWD/../target-root/usr/local install
popd

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

