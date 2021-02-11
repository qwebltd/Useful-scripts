<?php
/*
	This is a simple OpenCloud client written in PHP by QWeb Ltd, originally built to connect to Rackspace Cloud Files storage buckets and delete
	containers in bulk.

	Should run on just about any PHP server. Tested on LAMP stack.

	This uses the PHP OpenCloud libraries from https://github.com/rackspace/php-opencloud. You'll need to pull that library and copy it into
	/required/php-opencloud-working for this client to function.

	The code here is very minimalist. There's no real styling, no real security, and no real error checking. If you intend to use this you really
	should expand with at least some kind of a login mechanic, and wrap some of the functionality with better confirmation prompts and whatnot.

	Some operations might take a long time to complete. For example deleting containers with thousands of files. Depending on your server config,
	this might cauase timeouts to occur but the CDN itself will continue to parse the operation until completion. Again, you might want to expand
	this script to properly account for this behaviour, or run it with a PHP config that allows for very long execution timeouts.

	The download folders feature creates a local copy of the files in /temp, then compresses to a zip, and then triggers browser download before
	deleting these local files. As such, this feature requires /temp to be writable AND may consume a lot of disk space while operating.

	Working functionality:
		- Create containers
		- List containers
		- Delete containers (recursively)
		- Create folders
		- Upload files
		- List files and folders (recursively)
		- Download individual files
		- Download folders
		- Delete files and folders (recursively)

	POPULATE THESE VARIABLES TO USE:
*/

	$urlPrefix = '/openstack-client'; // If running in a sub directory, set this up inclusive of prefixing slash but not suffixing.
	$password = 'qwerty'; // Populate this with some kind of a password and then make sure you access this script with ?password= in the url

	$rackspaceUsername = ''; // Your Rackspace Cloud username
	$rackspaceAPIKey = ''; // Your Rackspace Cloud users API key, found in "My Profile & Settings" from the menu in the top right
	$rackspaceRegion = 'LON'; // Your Rackspace Files region code

/*
	THAT'S IT, YOU'RE DONE!
*/





	if(!isset($_GET['password']) || $_GET['password'] != $password) {
		header('HTTP/1.0 403 Forbidden');
		die('Authorisation denied.');
	}

	if($rackspaceUsername == '' || $rackspaceAPIKey == '')
		die('Set your Rackspace credentials up first.');

	// Rackspace Opencloud API
	require_once('required/php-opencloud-working/vendor/autoload.php');
	use OpenCloud\Rackspace;

	$rackspaceClient = new Rackspace(Rackspace::US_IDENTITY_ENDPOINT, array(
		'username' => $rackspaceUsername,
		'apiKey'   => $rackspaceAPIKey
	));

	$objectStoreService = $rackspaceClient->objectStoreService(null, $rackspaceRegion);

	// Pre render scripts
	if(isset($_POST['create-container'])) {
		$objectStoreService->createContainer($_POST['fldName']);

		// Redirect to containers list
		header('Location: '.$urlPrefix.'/?password='.$_GET['password']);
		exit;
	}

	if(isset($_GET['delete-container'])) {
		if($container = $objectStoreService->getContainer($_GET['delete-container']))
			$container->delete(true);

		// Redirect to containers list
		header('Location: '.$urlPrefix.'/?password='.$_GET['password']);
		exit;
	}

	if(isset($_POST['create-folder'])) {
		if($container = $objectStoreService->getContainer($_GET['container']))
			$container->uploadObject((isset($_GET['level']) ? $_GET['level'].'/' : '' ).$_POST['fldName'], '', array('Content-Type' => 'application/directory'));

		// Redirect to objects list
		header('Location: '.$_SERVER['REQUEST_URI']);
		exit;
	}

	if(isset($_POST['create-file'])) {
		if($container = $objectStoreService->getContainer($_GET['container'])) {
			if($_FILES['fldFile']['error'] == UPLOAD_ERR_OK) {
				$object = $container->uploadObject((isset($_GET['level']) ? $_GET['level'].'/' : '' ).$_FILES['fldFile']['name'], fopen($_FILES['fldFile']['tmp_name'], 'r'));

				// Clear CDN cache for this file in case it's a replacement
				try {
					$object->purge();
				} catch(Guzzle\Http\Exception\ClientErrorResponseException $e) {
					// Rackspace seems to impose rate limiting that causes this to sometimes crash, so this error trap is needed...
				}
			}
		}

		// Redirect to objects list
		header('Location: '.$_SERVER['REQUEST_URI']);
		exit;
	}

	if(isset($_GET['download-object'])) {
		if($container = $objectStoreService->getContainer($_GET['container'])) {
			if($object = $container->getObject(rawurlencode($_GET['download-object']))) {
				// Object might be a file or a folder
				if($object->getContentType() == 'application/directory') {
					// For folders, download each file to a temporary location, compress into a Zip archive, and then download that
					$bulkDirName = time();
					$bulkWorkingDirectory = substr($_SERVER['SCRIPT_FILENAME'], 0, strlen($_SERVER['SCRIPT_FILENAME']) - strlen($_SERVER['SCRIPT_NAME'])).$urlPrefix.'/temp/'.$bulkDirName.'/';
					mkdir($bulkWorkingDirectory);

					$bulkZip = new ZipArchive;
					$bulkZip->open($bulkWorkingDirectory.str_replace('/', '_', $object->getName()).'.zip', ZIPARCHIVE::CREATE);

					header("Content-type: application/octet-stream");
					header('Content-Disposition: attachment; filename='.str_replace('/', '_', $object->getName()).'.zip');
					header('Pragma: no-cache');
					header('Expires: '.gmdate('D, d M Y H:i:s', time()).' GMT');
					header('Cache-Control: max-age=0');

					// We can only grab 10,000 objects at a time and there could be more than that, so...
					$marker = '';

					// Unlinking before closing the zip seems to break things, so...
					$temporaryFiles = array();

					while($marker !== null) {
						$objects = $container->objectList(array(
							'prefix' => $_GET['download-object'].'/',
							'marker' => $marker,
						));

						$total = $objects->count();
						$count = 0;

						if($total > 0) {
							foreach($objects as $innerObject) {
								$count++;

								if($innerObject->getContentType() != 'application/directory') {
									// Create local dir structure
									$fullPath = $innerObject->getName();
									$pathArr = explode('/', $fullPath);
									$fileName = $pathArr[count($pathArr) - 1];
									unset($pathArr[count($pathArr) - 1]);

									$parentPath = '';
									foreach($pathArr as $paKey => $paVal) {
										if(!is_dir($bulkWorkingDirectory.$parentPath.$paVal))
											mkdir($bulkWorkingDirectory.$parentPath.$paVal);

										$parentPath .= $paVal.'/';
									}

									$temporaryFiles[] = $bulkWorkingDirectory.$fullPath;
									$innerObjectReal = $container->getObject(rawurlencode($innerObject->getName()));
									$objectContent = $innerObjectReal->getContent();
									$objectContent->rewind();
									$stream = $objectContent->getStream();
									file_put_contents($temporaryFiles[count($temporaryFiles) - 1], $stream);
									$bulkZip->addFile($temporaryFiles[count($temporaryFiles) - 1], $fileName);
								}

								$marker = ($count == $total ? $innerObject->getName() : null);
							}
						} else
							$marker = null;
					}

					$bulkZip->close();
					readfile($bulkWorkingDirectory.str_replace('/', '_', $object->getName()).'.zip');
					unlink($bulkWorkingDirectory.str_replace('/', '_', $object->getName()).'.zip');

					// Now we can unlink the files
					foreach($temporaryFiles as $fKey => $fVal) {
						unlink($fVal);
					}
				} else {
					header('Content-Type: '.$object->getContentType());
					header('Content-Disposition: attachment; filename='.$object->getName());
					header('Pragma: no-cache');
					header('Expires: 0');

					echo $object->getContent();
				}
			}
		}

		exit;
	}

	if(isset($_GET['delete-object'])) {
		if($container = $objectStoreService->getContainer($_GET['container'])) {
			if($object = $container->getObject(rawurlencode($_GET['delete-object']))) {
				// Object might be a file or a folder
				if($object->getContentType() == 'application/directory') {
					// Delete folders recursively...

					// We can only grab 10,000 objects at a time and there could be more than that, so...
					$marker = '';
					$paths = array();

					while($marker !== null) {
						$objects = $container->objectList(array(
							'prefix' => $_GET['delete-object'].'/',
							'marker' => $marker,
						));

						$total = $objects->count();
						$count = 0;

						if($total > 0) {
							foreach($objects as $innerObject) {
								$count++;

								$paths[] = '/'.$_GET['container'].'/'.$innerObject->getName();

								$marker = ($count == $total ? $innerObject->getName() : null);
							}
						} else
							$marker = null;
					}

					if(!empty($paths))
						$objectStoreService->batchDelete($paths);

					$object->delete();
				} else
					$object->delete();
			}
		}

		// Redirect to objects list
		header('Location: '.$urlPrefix.'/?password='.$_GET['password'].'&container='.$_GET['container'].'&level='.$_GET['parent']);
		exit;
	}

	// Page header
	require_once('structure/header.php');

	if(isset($_GET['container'])) {
		// If container is selected, show files...
		$container = $objectStoreService->getContainer($_GET['container']);

		// One level at a time
		if(isset($_GET['level']))
			$level = $_GET['level'];
		else
			$level = '';

		// We can only grab 10,000 objects at a time and there could be more than that in a container, so...
		$marker = '';
		$objects = array();

		while($marker !== null) {
			$results = $container->objectList(array(
				'prefix' => $level,
				'marker' => $marker,
			));

			$total = $results->count();
			$count = 0;

			if($total > 0) {
				foreach($results as $object) {
					$count++;

					// If object name contains a slash that isn't part of the level we're in, it must be within a deeper level, so...
					if(strpos(substr($object->getName(), strlen($level)), '/') === false)
						$objects[$object->getName()] = $object;

					$marker = ($count == $total ? $object->getName() : null);
				}
			} else
				$marker = null;
		}

		ksort($objects);

		// Page content
		require_once('includes/objects-list.php');
	} else {
		// If no container is selected, show containers...
		$containers = $objectStoreService->listContainers();

		$objects = array();

		foreach($containers as $object) {
			$objects[$object->getName()] = $object;
		}

		ksort($objects);

		// Page content
		require_once('includes/container-list.php');
	}

	// Page footer
	require_once('structure/footer.php');
?>
