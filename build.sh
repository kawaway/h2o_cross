#!/bin/bash

SYSROOT=`pwd`/target

CROSS=1
if [ "x$1" = "xpclinux" ]; then
	CROSS=0
fi

h2o_install()
{
	cd h2o
	make install
	cd ..
	mkdir -p ${SYSROOT}/etc/h2o ${SYSROOT}/var/log/h2o ${SYSROOT}/usr/www/html
	cp -pr h2o/examples/h2o $SYSROOT/etc
	# install my h2o.conf 
	cp h2o-single.conf $SYSROOT/etc/h2o.conf
	cp -pr h2o/examples/doc_root/index.html $SYSROOT/usr/www/html

	cd ..
}

h2o_make()
{
	if [ ! -d h2o ]; then 
		git clone https://github.com/h2o/h2o.git
		git checkout -b v2.2.0 refs/tags/v2.2.0
	fi

	cd h2o

	if [ $CROSS -eq 1 ]; then
		patch --forward -p1 < ../cross_mruby.patch
		patch --forward -p1 < ../cross_mruby-file-stat.patch
		patch --forward -p1 < ../cross_mruby_path.patch
		patch --forward -p1 < ../cross_libressl.patch
		cmake -DWITH_MRUBY=on -DCMAKE_INSTALL_PREFIX=$SYSROOT -DCMAKE_TOOLCHAIN_FILE=`pwd`/../linux-arm.cmake .
		# debug cmake
		#cmake --debug-output --trace -DWITH_MRUBY=on -DCMAKE_INSTALL_PREFIX=$SYSROOT -DCMAKE_TOOLCHAIN_FILE=`pwd`/../linux-arm.cmake .
	else # pclinux
		cmake -DWITH_MRUBY=on -DCMAKE_INSTALL_PREFIX=$SYSROOT .
	fi
	#patch --forward -p1 < ../O0.patch
	make
	cd ..
}

h2o_clean(){
	cd h2o && make clean && cd ..
}

zlib_make()
{
	ZLIB_VERSION=1.2.11
	if [ ! -d zlib-${ZLIB_VERSION} ]; then 
		curl -L http://prdownloads.sourceforge.net/libpng/zlib-${ZLIB_VERSION}.tar.gz?download | tar zx
	fi

	cd zlib-${ZLIB_VERSION}
	CC=${CROSS_COMPILE}gcc ./configure --prefix=${SYSROOT} && make && make install
	cd ..
}

zlib_clean()
{
	cd zlib && make clean
}

if [ "x$1" = "xclean" ]; then
	h2o_clean
else
	[ $CROSS -eq 1 ] && zlib_make
	h2o_make
	h2o_install
fi
