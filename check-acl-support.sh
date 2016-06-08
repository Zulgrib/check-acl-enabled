#!/bin/sh
PATHTOCHECK=$1
{
	# Determine what the mount point for the path is:
	MOUNT_POINT=$(df -P $PATHTOCHECK | tail -n 1 | awk '{print $6}')
	FILESYSTEM=$(df -P $PATHTOCHECK | tail -n 1 | awk '{print $1}')
	# Get the mount options for the path:
	MOUNT_OPTS=$(awk '$2=="'$MOUNT_POINT'" { print $4 }' /proc/mounts)
	# Check to see if acl is one of the mount points:
	echo $MOUNT_OPTS | tr , \\\n | grep '^acl$' -q
	if [ $? -eq 0 ]; then
		echo "ACLs enabled on $PATHTOCHECK"
		exit 0;
	else
		echo "ACLs disabled"
		tune2fs -l $FILESYSTEM | grep "Default mount options:" | grep "acl" -q
		
		if [ $? -eq 0 ]; then
			echo "ACLs enabled on $PATHTOCHECK"
			exit 0;
		else
			echo "ACLs disabled on $PATHTOCHECK"
			exit 1;
		fi
	fi
}