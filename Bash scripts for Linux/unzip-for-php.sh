#!/bin/bash

# Unzip utility by QWeb Ltd
# PHP's ZipArchive utility doesn't preserve symlinks when extracting zips, so we built this basic wrapper for the Linux unzip command

# Usage: sh unzip-for-php.sh source_filename destination_dir

# To use this from a PHP script requires exec() support. Usually you'd pass uploaded files to this directly, llke this:
#		<?php
#			$extract = exec('path/to/unzip-for-php.sh "'.$_FILES['fldUploadedZipFile']['tmp_name'].'" "path/to/destination/directory"');
#			if($extract == 'done') {
#				// Files have extracted, do something here
#			}
#		?>


# Check the source file exists
if test -f "$1"; then
	echo "$1 found"

	# Check source is a zip file
	if [[ $(file $1) == *"Zip archive data"* ]]; then
		echo "$1 is a valid zip file"

		# Check the destination exists
		if test -d "$2"; then
			echo "$2 found"

			# Extract source to destination
			unzip $1 -d $2

			echo "done"
		else
			echo "$2 not found"
		fi
	else
		echo "$1 is not a valid zip file"
	fi
else
	echo "$1 not found"
fi
