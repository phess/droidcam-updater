#!/usr/bin/env bash

## Download, compile, and install the droidcam driver for the current kernel
## version if not done already.

KERNELVERSION="$(uname -r)"
MODULEPATH="/lib/modules/${KERNELVERSION}/kernel/drivers/media/video"
MODULEFILE="v4l2loopback-dc.ko"
TMPDIR="$XDG_RUNTIME_DIR/tmp"
UNZIPDIR=${TMPDIR}/droidcam

# Running in debug mode? (argument `-d' was passed?)
[[ "$*" =~ "-d" ]] && DEBUG=1

# Specify debug output
if [ -z "$DEBUG" ]
then
        DEBUGOUT=/dev/null
else
        DEBUGOUT=/dev/stdout
        echo "DEBUG output enabled" > $DEBUGOUT
fi

# Does the module exist already?
test -f ${MODULEPATH}/${MODULEFILE} && echo "Module exists already at ${MODULEPATH}/${MODULEFILE}. Exiting now." && exit 0

# Module does not exist.
# 1. Download it
DOWNLOADURL="https://files.dev47apps.net/linux/droidcam_latest.zip"
DOWNLOADFILE="droidcam_latest.zip"
mkdir -v -p "${TMPDIR}" > $DEBUGOUT
DOWNLOADCMD="wget -P ${TMPDIR} ${DOWNLOADURL}"
test -f ${TMPDIR}/${DOWNLOADFILE} || $DOWNLOADCMD

# 2. Test file integrity -- no more since 2020-11-10 or earlier
#echo "73db3a4c0f52a285b6ac1f8c43d5b4c7 ${DOWNLOADDIR}/${DOWNLOADFILE}" | md5sum -c --

# 2. Are the necessary packages installed? Install them if not
echo "Checking if all required packages are installed. I will install them if necessary."
rpm -q "kernel-headers-$(uname -r)" && rpm -q "gcc" && rpm -q "make" &>/dev/null || sudo dnf -y install "kernel-headers-$(uname -r)" gcc make || exit 6

# 3. unzip it
unzip ${TMPDIR}/${DOWNLOADFILE} -d ${UNZIPDIR}

# 4. cd into $UNZIPDIR and compile/install it
( cd ${UNZIPDIR} && sudo ./install )
