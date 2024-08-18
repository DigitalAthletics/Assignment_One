#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # ----------------------------------------------------------------------------------

    # TODO: Add your kernel build steps here
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper  #clean everything to unpacked state
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig #default config
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all   #
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs      #device tree basics
fi

echo "Adding the Image in outdir"
cp -r "${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image" "${OUTDIR}/Image"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Create necessary base directories"
mkdir -p "$OUTDIR/rootfs"
cd "$OUTDIR/rootfs"
mkdir -p bin 
mkdir -p dev 
mkdir -p etc 
mkdir -p home 
mkdir -p lib 
mkdir -p lib64 
mkdir -p proc 
mkdir -p sys 
mkdir -p sbin 
mkdir -p tmp 
mkdir -p usr
mkdir -p usr/bin 
mkdir -p usr/sbin 
mkdir -p usr/lib 
mkdir -p var
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "Configure busybox"
    make distclean #remove stuff created before
    make defconfig #default config
else
    cd busybox
fi

# TODO: Make and install busybox
echo "Make and install busybox"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd "${OUTDIR}/rootfs"

echo "Library dependencies"
pwd
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cd ${SYSROOT}
pwd
cp lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
cp lib64/libc.so.6 ${OUTDIR}/rootfs/lib64
cp lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64

# TODO: Make device nodes, with major device type 1 and 5, and minor types 3 and 1
echo "Make device nodes"
cd "${OUTDIR}/rootfs"
sudo mknod -m 666 dev/null c 1 3    #create node type 1, 3
sudo mknod -m 666 dev/console c 5 1 #create node type 5, 1

# TODO: Clean and build the writer utility
echo "Clean and build the writer utility"
cd "${FINDER_APP_DIR}"
make CROSS_COMPILE=${CROSS_COMPILE}
#make CROSS_COMPILE=aarch64-none-linux-gnu- clean
#make CROSS_COMPILE=aarch64-none-linux-gnu- all

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "Copy the finder related scripts and executables to the /home directory on the target rootfs"
cp finder.sh ${OUTDIR}/rootfs/home
cp writer ${OUTDIR}/rootfs/home
cp autorun-qemu.sh ${OUTDIR}/rootfs/home
cp finder-test.sh ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
echo "Chown the root directory"
sudo chown -R root:root ${OUTDIR}/rootfs
cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio

# TODO: Create initramfs.cpio.gz
echo "Create initramfs.cpio.gz at:"
echo ${OUTDIR}
cd ${OUTDIR}
gzip -f ${OUTDIR}/initramfs.cpio
