SOURCE_DIR=.
VERSION=2.4.4
ARCHIVE=$(SOURCE_DIR)/libressl-$(VERSION).tar.gz
DEST=libressl-build
UNAME=$(shell uname -s)

all: $(DEST)/lib/libssl.a

$(DEST)/lib/libssl.a: $(ARCHIVE)
	if [ ! -e "libressl-$(VERSION)" ] ; then tar xzf "$(ARCHIVE)" ; fi
	if [ ! -e "libressl-$(VERSION)/Makefile" ] ; then (P=`pwd`/$(DEST); cd libressl-$(VERSION) && CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld CCLD=$LD AR=${CROSS_COMPILE}ar CXX=${CROSS_COMPILE}g++ CPP=${CROSS_COMPILE}cpp RANLIB=${CROSS_COMPILE}ranlib ./configure --host=arm-linux-gnueabi --prefix="$$P" --libdir="$$P/lib" --disable-shared `test "$(UNAME)" = "Darwin" && echo '--disable-asm'`) ; fi
	(cd libressl-$(VERSION) && make && make install)
