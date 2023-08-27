#!/bin/bash

# Compression utility by QWeb Ltd
# PHP's Phar utility doesn't handle symlinks well, so we built this basic wrapper for the Linux tar command. Probably also more efficient than Phar, though this isn't tested.

# Usage: sh targz-for-php.sh source_dir destination_filename

# To use this from a PHP script requires exec() support.
#		<?php
#			$compress = exec('path/to/targz-for-php.sh "path-to-compress" "path/to/destination/file-to-create.tar.gz"');
#			if($compress == 'done') {
#				// Destination file should now exist, do something here
#			}
#		?>


# Check the source dir exists
if test -d "$1"; then
	echo "$1 found"

	# Compress source to destination
	tar -czvf $2 -C $1 .

	echo "done"
else
	echo "$1 not found"
fi
