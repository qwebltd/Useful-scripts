# Simple OpenCloud PHP Client
This is a simple OpenCloud/OpenStack client written in PHP by QWeb Ltd, originally built to connect to Rackspace Cloud Files storage buckets and delete containers in bulk.

Should run on just about any PHP server. Tested on LAMP stack.

The code here is very minimalist. There's no real styling, no real security, and no real error checking. If you intend to use this in a production environment you really should expand with at least some kind of a login mechanic, and wrap some of the functionality with better confirmation prompts and whatnot. That said, the minimalism makes it really easy to follow and expand upon.

Some operations might take a long time to complete. For example deleting containers with thousands of files. Depending on your server config, this might cauase timeouts to occur but the CDN itself will continue to parse the operation until completion. Again, you might want to expand this script to properly account for that behaviour, or run it with a PHP config that allows for very long execution timeouts.

The download folders feature creates a local copy of the files in /temp, then compresses to a zip, and then triggers browser download before deleting these local files. As such, this feature requires /temp to be writable AND may consume a lot of disk space while operating.

## Working Functionality
The PHP OpenCloud libraries are fairly extensive. This client was built to support just the things we needed it to

- Create containers
- List containers
- Delete containers (recursively)
- Create folders
- Upload files
- List files and folders (recursively)
- Download individual files
- Download folders
- Delete files and folders (recursively)

## Setting Up
- Copy this entire folder into a /var/www/httpdocs tree or relevant vhosts configuration
- Download the PHP OpenCloud libraries from https://github.com/rackspace/php-opencloud and copy into the /required/php-opencloud-working folder
- Open /index.php and edit the few variables at the top, to configure the script with your own Rackspace Cloud or other OpenStack service credentials
- Then just navigate to this webspace in a web browser, suffixing the url with ?password= as per the password variable configured in /index.php

## Other OpenStack Services
Rackspace Cloud is an OpenStack based service and its OpenCloud libraries are thus built around the OpenStack SDK. You can therefore use their library, and our client, to connect to any OpenStack service. Unless the service you choose does not properly follow the standard OpenStack API, there shouldn't be any need to modify this code.

## Support
I'm an advocate of open source, FOSS, FSF, and such. Like all other scripts and tools within this repository, this code is provided for free in the hopes it's useful to somebody. If you found this helpful and want to show your support, donations are always greatly appreciated.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N1GXJ1U)
