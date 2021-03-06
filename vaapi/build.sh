#!/bin/bash -ex

export PREFIX=$PWD/../target-root/usr/local
export LDFLAGS="-L$PREFIX/lib"
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

if [ ! -f .deps ]; then
	sudo yum -y install libwayland-client
	sudo yum -y install libpciaccess-devel
	sudo yum -y install xorg-x11-drv-intel
	sudo yum -y install libXext-devel
	sudo yum -y install libXfixes-devel
	sudo yum -y install xorg-x11-util-macros

	# intel_gpu_top command needs kernels 4.18 or higher.
	sudo yum -y install kmod-devel procps-ng-devel libunwind-devel elfutils-devel cairo-devel libudev-devel
	touch .deps
fi

if [ ! -d intel-gpu-tools ]; then
	git clone git://anongit.freedesktop.org/xorg/app/intel-gpu-tools
fi

if [ ! -d libva ]; then
	git clone https://github.com/intel/libva.git
fi

if [ ! -d libva-utils ]; then
	git clone https://github.com/intel/libva-utils.git
	pushd libva-utils/putsurface
		patch <../../01.patch
	popd
	pushd libva-utils
		patch -p1 <../02.patch
	popd
fi

if [ ! -d intel-vaapi-driver ]; then
	git clone https://github.com/intel/intel-vaapi-driver.git
fi

if [ ! -f libdrm-2.4.99.tar.gz ]; then
	wget https://dri.freedesktop.org/libdrm/libdrm-2.4.99.tar.gz
fi

if [ ! -d libdrm-2.4.99 ]; then
	tar zxf libdrm-2.4.99.tar.gz
fi


pushd libdrm-2.4.99
	if [ ! -f .skip ]; then
		export CFLAGS="-I$PREFIX/include"
		export CXXFLAGS=$CFLAGS
		./configure --prefix=$PREFIX \
			--disable-radeon  \
			--disable-amdgpu  \
			--disable-nouveau \
			--disable-vmwgfx  
		make
		make install
		touch .skip
	fi
popd

pushd libva
	if [ ! -f .skip ]; then
		export CFLAGS="-I$PREFIX/include"
		export CXXFLAGS=$CFLAGS
		./autogen.sh
		./configure --prefix=$PREFIX --enable-va-messaging --enable-x11
		make
		make install
		touch .skip
	fi
popd

pushd libva-utils
	if [ ! -f .skip ]; then
		export CFLAGS="-I$PREFIX/include --std=c99"
		export CXXFLAGS=$CFLAGS
		./autogen.sh
		./autogen.sh
		./configure --prefix=$PREFIX
		make
		make install
		touch .skip
	fi
popd


pushd intel-vaapi-driver
	if [ ! -f .skip ]; then
		export CFLAGS="-I$PREFIX/include"
		export CXXFLAGS=$CFLAGS
		./autogen.sh
		./configure --prefix=$PREFIX
		make
		make install
		touch .skip
	fi
popd

# GCC 4.8 bug, missing stdatomic header
GCCVERSION=`gcc --version | head -1`
if [ "$GCCVERSION" != "gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-36)" ]; then
	pushd intel-gpu-tools
		if [ ! -f .skip ]; then
			export CFLAGS="-I$PREFIX/include"
			export CXXFLAGS=$CFLAGS
			./autogen.sh
			./configure --prefix=$PREFIX
			make
			make install
			touch .skip
		fi
	popd
fi

