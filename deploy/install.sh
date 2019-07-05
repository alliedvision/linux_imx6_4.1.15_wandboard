#!/bin/bash
#==============================================================================
# Copyright (C) 2019 Allied Vision Technologies.  All Rights Reserved.
#
# Redistribution of this file, in original or modified form, without
# prior written consent of Allied Vision Technologies is prohibited.
#
#------------------------------------------------------------------------------
#
# File:         -install.sh
#
# Description:  -bash script for installing the kernel and CSI-2 driver
#
#------------------------------------------------------------------------------
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF TITLE,
# NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE ARE
# DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#==============================================================================

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
REQ_MACHINE="Wandboard"
REQ_KERNEL="4.1.15"
MACHINE="$(cat /sys/devices/soc0/machine)"
REV="$(cat /sys/devices/soc0/revision)"
DEST="/media/avsd_root"

echo -e ${RED}"Allied Vision"${NC}" MIPI CSI-2 camera driver for "${GREEN}${REQ_MACHINE}${NC}" (kernel "${REQ_KERNEL}")"
echo -e "Machine:  "${MACHINE}
echo -e "Revision: "${REV}

A="$(tr \"[:upper:]\" \"[:lower:]\" <<< "$MACHINE" )"
B="$(tr \"[:upper:]\" \"[:lower:]\" <<< "$REQ_MACHINE" )"

if ! [[ ${A} = *${B}* ]];then
	echo -e ${RED}"Wrong machine type!"${NC}
	exit 1
fi
if ! [[ "$(uname -r)" == ${REQ_KERN}* ]];then
	echo -e ${RED}"Wrong kernel version!"${NC}
	exit 1
fi


# ========================================================= usage function
usage() {
	echo -e "Options:"	
	echo -e "-h:\t Display help"
	echo -e "-y:\t Automatic install and reboot"
	exit 0
}

inst() {
	# Mount boot partition		
	sudo mkdir ${DEST}
	sudo mount /dev/mmcblk2p1 ${DEST}
	# Check, if correct partition		
	if [ -f ${DEST}"/zImage" ];then
		# Copy zImage + DTBs to boot partition
		sudo cp -r zImage $DEST
		sudo cp -r *.dtb $DEST

		# Extact modules
		sudo tar zxvf modules.tar.gz -C /
	else
		echo -e ${RED}"Can't detect boot partition!"${NC}
	fi

	sudo umount ${DEST}
	sudo rmdir ${DEST}
}


if [[ ( $1 == "-help") || ( $1 == "-h") ]];then
	usage
fi	

if [[ ( $1 == "-y")]];then
	inst
	sudo init 6
	exit 0
fi	


read -p "Install kernel driver (y/n)? " answer
case $answer in
	[Yy]* )
		echo -e "\nInstalling..."
		inst
	;;
	[Nn]* )
	 	echo -e
	;;
esac

read -p "Reboot now (y/n)? " answer
case $answer in
	[Yy]* )
		echo -e "Reboot..."
		sudo init 6
	;;
	[Nn]* )
	 	echo -e
		exit 0
	;;
esac

exit 0

