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
DOWNLOADDIR=~/Downloads
DOWNLOADCMD="wget -P ${DOWNLOADDIR} ${DOWNLOADURL}"
test -f ${DOWNLOADDIR}/${DOWNLOADFILE} || $DOWNLOADCMD

# 2. Test file integrity -- no more since 2020-11-10 or earlier
#echo "73db3a4c0f52a285b6ac1f8c43d5b4c7 ${DOWNLOADDIR}/${DOWNLOADFILE}" | md5sum -c --

# 3. unzip it
unzip ${DOWNLOADDIR}/${DOWNLOADFILE} -d ${UNZIPDIR}

# 4. cd into $UNZIPDIR and compile/install it
( cd ${UNZIPDIR} && sudo ./install )
