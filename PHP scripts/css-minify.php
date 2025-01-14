<?php
	/* This script combines the contents of CSS files and strips out unnecessary content to create a smaller, single file for faster page loads.
	 * 
	 * It doesn't aim for perfect minification. For that, to avoid things like the removal of spaces inside strings would be complex.
	 * We'd probably need to do actual lexical analysis and transpile CSS back into CSS for accuracy, which seems overkill.
	 * 
	 * This script creates cache files in the same directory it's located, and checks the file mod times of each origin CSS file to know when regeneration is needed.
	 * You can also pass a v= url parameter to skip the file mod time check and just force return of a specific version. Passing a manually defined version number or the max filemtime from your CSS files is a good way to refresh browser caches.
	 * 
	 * Remember to update $minifyFiles below with a list of your own CSS files. They don't have to be in the same folder as this script.
	 * 
	 * It's recommended that you define a pseudo url in your .htaccess to point to this script, and reference that within your HTML. E.g.
	 * 	.htaccess:	RewriteRule ^styles/min.css styles/css-minify.php [NC,L]
	 * 	html:		<link rel="stylesheet" href="/styles/min.css?v=20250114" type="text/css" media="screen" />
	 */

	header('Content-type: text/css');

	// The files to combine, in the order to combine them
	$minifyFiles = array(
		__DIR__.DIRECTORY_SEPARATOR.'screen.css',
		__DIR__.DIRECTORY_SEPARATOR.'responsive.css',
	);

	// We want to cache the result for performance
	// We use a hash for the actual filenames, because it's a convenient way to prevent malicious path injections which file_get_contents() and file_put_contents() might then follow
	if(isset($_GET['v']))
		$cacheFile = 'minified-'.sha1($_GET['v']).'.css';
	else {
		$maxMtime = 0;
		foreach($minifyFiles as $key => $filename) {
			$maxMtime = max($maxMtime, filemtime($filename));
		}

		$cacheFile = 'minified-'.sha1($maxMtime).'.css';
	}

	// Delete all cache files older than 1 day, except for this one. There shouldn't ever be more than a couple
	$handler = opendir(__DIR__);

	while($file = readdir($handler)) {
		if($file != $cacheFile && preg_match('/minified-([0-9a-f]*)?\.css/mgi', $file) && filemtime($file) < time() - 86400) {
			unlink(__DIR__.DIRECTORY_SEPARATOR.$file);
		}
	}

	closedir($handler);

	// If there's a cache file to use, just spit it out and end here
	if(is_file(__DIR__.DIRECTORY_SEPARATOR.$cacheFile))
		echo file_get_contents(__DIR__.DIRECTORY_SEPARATOR.$cacheFile);
	else {
		// No cache, continue

		// Function to process CSS and return a minified version
		if(!function_exists('minifyCss')) {
			function minifyCss($css) {
				// This tries not to be too destructive. We're not aiming for unreadable obsessive minimalisation, just quick loading.

				// Remove comments
				$css = preg_replace('/\/\*(?:.(?!\/)|[^\*](?=\/)|(?<!\*)\/)*\*\//s', '', $css);

				// Remove excess whitespace and line breaks between properties
				$css = preg_replace('/;[\s\r\n]*/', '; ', $css);

				// Remove excess whitespace after opening property blocks
				$css = preg_replace('/{[\s\r\n]*/', '{ ', $css);

				// Remove excess whitespace between selectors
				$css = preg_replace('/,[\r\n][\s\r\n]*/sm', ',', $css);

				// Remove empty lines
				$css = preg_replace('/^[\s\r\n]*/sm', '', $css);

				return $css;
			}
		}

		// Iterate the files we want to minify, adding them to the cache file and outputting them here as we go
		foreach($minifyFiles as $key => $filename) {
			$minified = minifyCss(file_get_contents($filename));
			echo $minified;
			file_put_contents(__DIR__.DIRECTORY_SEPARATOR.$cacheFile, $minified, FILE_APPEND);
		}
	}
