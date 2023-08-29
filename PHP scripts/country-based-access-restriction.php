<?php
  /* This script whitelists individual countries, using the IP lookup API at https://apis.qweb.co.uk to check the visitors country against this list.
   *
   * To use this script:
   * - copy this script to the very top of a PHP file you want to restrict access to. Usually an admin panel login page
   * - create an ip-lookup-cache folder in the same location as that script
   * - create an API access key at https://apis.qweb.co.uk/console and populate the $accessKey variable.
   * - then populate $countries with a list of the 2 letter country codes you want to grant access to: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
   */

  $accessKey = 'YOUR API ACCESS KEY HERE';
  $countries = array('GB');

  // We cache the lookups for 1 week for better performance
	$cacheFile = 'ip-lookup-cache'.DIRECTORY_SEPARATOR.preg_replace('/[^0-9a-f]/', '_', $_SERVER['REMOTE_ADDR']).'.json';

	if(is_file($cacheFile) && filemtime($cacheFile) >= time() - 604800)
		$response = file_get_contents($cacheFile);
	else {
		$api = curl_init();
		curl_setopt($api, CURLOPT_URL, 'https://apis.qweb.co.uk/ip-lookup/'.$accessKey.'/'.$_SERVER['REMOTE_ADDR'].'.json');
		curl_setopt($api, CURLOPT_RETURNTRANSFER, 1);
		$response = curl_exec($api);
		curl_close($api);

		file_put_contents($cacheFile, $response);
	}

	$data = json_decode($response);
	if($data->answer == 'success') {
		if($data->is_proxy == 'yes' || !in_array($data->country, $countries)) {
			header('HTTP/1.0 403 Forbidden');
			exit;
		}
	}
?>
