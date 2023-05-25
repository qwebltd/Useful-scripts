<?php
	/*
		This version uses DIRECTORY_SEPARATOR instead of /, for better cross platform support.

		This version supports passing a cache time to dbQuery, in seconds.

		The recordset of cacheable queries is kept in a file and used by dbQuery, dbFetch, dbFetchAll, and dbNumRows instead of further database calls.

		If a cache already exists for the query that's within the cacheable time, no database communication happens at all.

		If a cache doesn't exist or is older than the passed cache time, and the query is cacheable (cachetime of at least 1), a new cache file is generated.

		NEVER try to make INSERT/REPLACE etc queries cacheable. This should ONLY be used for queries that return a recordset.

		The concept is actually pretty simple. When dbQuery is called, it either returns a regular recordset, or the name of a cache file suffixed with a random value.
		dbFetch, dbFetchAll, and dbNumRows check if what they've been passed is a recordset or a cache file reference, and operate accordingly.
		dbFetch uses the cache file name + the random suffix as a key for an iterations array, which simply stores the next resultset row ID.

		Create sql-cache folders in the website root and in any folder that contains a cron script. Or at the top of a cron script, before including database.php, do the following to force this script to look in the root level sql-cache folder instead:
			$_SERVER['DOCUMENT_ROOT'] = $_SERVER['PWD'].DIRECTORY_SEPARATOR.'..'.DIRECTORY_SEPARATOR;

		This version also includes dbClearCache(), useful to call after queries that need to take immediate effect.

		---

		This version incorporates encryption functions for GDPR compliance.

		dbEncrypt() is a function that adds seeds to the given value and then generates a SHA1 hash for one-way encryption. Use this instead of SQL's SHA1() function for things like passwords.

		dbObfuscate() is a function that skews a string, allowing it to be saved in an unreadable form but deciphered again later on. Use this for personal data that doesn't need to be full text searched, like an email address.

		dbDecipher() is a function that reverses an obfuscated string, allowing for securely saved data to be reverted back into useful form again.
	*/

	// Initiation
	if(function_exists('mysqli_connect')) {
		$db = mysqli_connect($dbHostname, $dbUsername, $dbPassword, $dbDatabase);
		mysqli_set_charset($db, 'utf8');
	} else {
		$db = mysql_connect($dbHostname, $dbUsername, $dbPassword);
		mysql_set_charset('utf8', $db);
		mysql_select_db($dbDatabase);
	}

	/*
		dbFetch() normally uses MySQL's in-built recordset iteration to grab the next result each time it's called.
		For cached queries we need our own iteration system, so..
	*/
	$dbIterations = array();

	// Cron jobs need this instead.
	if(empty($_SERVER['DOCUMENT_ROOT']))
		$_SERVER['DOCUMENT_ROOT'] = $_SERVER['PWD'];

	if(!function_exists('dbQuery')) {
		function dbQuery($sql, $cachetime = 0) {
			global $db;

			// incase we can't get to the cache directory
			if($cachetime > 0 && !is_dir($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'))
				$cachetime = 0;

			if($cachetime > 0) {
				if(is_file($_SERVER['DOCUMENT_ROOT'].'/sql-cache/'.sha1($sql).'.txt')) {
					$data = file_get_contents($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.sha1($sql).'.txt');
					$data2 = json_decode($data, true);

					if($data2['time'] >= time() - $cachetime)
						$result = sha1($sql).'.txt.'.rand(); // The random suffix is to allow multiple calls to dbQuery with the same SQL, to be handled individually by the iterator
				}

				if(!isset($result)) {
					if(function_exists('mysqli_query'))
						$result = mysqli_query($db, $sql);
					else
						$result = mysql_query($sql, $db);

					$data = json_encode(array(
						'time' => time(),
						'results' => dbFetchAll($result)
					));

					if(is_file($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.sha1($sql).'.txt'))
						unlink($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.sha1($sql).'.txt');

					file_put_contents($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.sha1($sql).'.txt', $data);

					$result = sha1($sql).'.txt.'.rand(); // The random suffix is to allow multiple calls to dbQuery with the same SQL, to be handled individually by the iterator
				}
			} else {
				if(function_exists('mysqli_query'))
					$result = mysqli_query($db, $sql);
				else
					$result = mysql_query($sql, $db);
			}

			return $result;
		}
	}

	if(!function_exists('dbUnbufferedQuery')) {
		function dbUnbufferedQuery($sql) {
			global $db;

			if(function_exists('mysqli_query'))
				return mysqli_query($db, $sql, MYSQLI_USE_RESULT);
			else
				return mysql_unbuffered_query($sql, $db);
		}
	}

	// Line indents etc have to be exactly as per the query being uncached
	if(!function_exists('dbClearQueryCache')) {
		function dbClearQueryCache($sql) {
			if(is_file($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.sha1($sql).'.txt')) {
				unlink($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.sha1($sql).'.txt');
				return true;
			} else
				return false;
		}
	}

	if(!function_exists('dbEscape')) {
		function dbEscape($str) {
			global $db;

			if(function_exists('mysqli_real_escape_string'))
				return mysqli_real_escape_string($db, $str);
			else
				return mysql_real_escape_string($str, $db);
		}
	}

	if(!function_exists('dbFetch')) {
		function dbFetch($recordSet) {
			if(!is_object($recordSet)) {
				global $dbIterations;

				$data = file_get_contents($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.substr($recordSet, 0, 44));
				$data2 = json_decode($data, true);
				$records = $data2['results'];

				if(!isset($dbIterations[$recordSet]))
					$dbIterations[$recordSet] = 0;

				if(isset($records[$dbIterations[$recordSet]])) {
					$result = $records[$dbIterations[$recordSet]];
					$dbIterations[$recordSet]++;
					return $result;
				} else
					return false;
			} else {
				global $db;

				if(function_exists('mysqli_fetch_assoc'))
					return mysqli_fetch_assoc($recordSet);
				else
					return mysql_fetch_assoc($recordSet);
			}
		}
	}

	if(!function_exists('dbNumRows')) {
		function dbNumRows($recordSet) {
			if(!is_object($recordSet)) {
				$data = file_get_contents($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.substr($recordSet, 0, 44));
				$data2 = json_decode($data, true);
				return count($data2['results']);
			} else {
				global $db;

				if(function_exists('mysqli_num_rows'))
					return mysqli_num_rows($recordSet);
				else
					return mysql_num_rows($recordSet);
			}
		}
	}

	if(!function_exists('dbFetchAll')) {
		function dbFetchAll($recordSet) {
			if(!is_object($recordSet)) {
				$data = file_get_contents($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache'.DIRECTORY_SEPARATOR.substr($recordSet, 0, 44));
				$data2 = json_decode($data, true);
				return $data2['results'];
			} else {
				global $db;
				$results = array();

				if(function_exists('mysqli_fetch_assoc')) {
					while($row = mysqli_fetch_assoc($recordSet)) {
						$results[] = $row;
					}
				} else {
					while($row = mysql_fetch_assoc($recordSet)) {
						$results[] = $row;
					}
				}

				return $results;
			}
		}
	}

	if(!function_exists('dbGetLastInsertId')) {
		function dbGetLastInsertId() {
			global $db;

			if(function_exists('mysqli_insert_id'))
				return mysqli_insert_id($db);
			else
				return mysql_insert_id($db);
		}
	}

	if(!function_exists('dbEncrypt')) {
		function dbEncrypt($str) {
			global $dbEncryptSeed;

			return sha1($dbEncryptSeed . $str . strrev($dbEncryptSeed));
		}
	}

	if(!function_exists('dbObfuscationMap')) {
		$cachedObfuscationMap = array();
		function dbObfuscationMap() {
			global $dbEncryptSeed;
			global $cachedObfuscationMap;

			if(!empty($cachedObfuscationMap))
				return $cachedObfuscationMap;
			else {
				$raw = range('0 ', 'z');
				$map = array();

				$shift = 0;
				foreach(str_split($dbEncryptSeed) as $char) {
					$shift += (int)array_search((string)$char, $raw);
				}

				$shuffled = $raw;
				foreach(str_split($dbEncryptSeed.'750qwERty') as $char) {
					$position = array_search((string)$char, $shuffled);

					if($position !== false && $position > 0 && $position < count($shuffled)) {
						$left = array_slice($shuffled, 0, $position);
						$right = array_slice($shuffled, $position);
						$shuffled = array_merge($right, array_reverse($left));
					}
				}

				foreach($raw as $key => $val) {
					reset($shuffled);
					for($i = $shift + $key; $i > 0; $i--) {
						if(next($shuffled) === false)
							reset($shuffled);
					}

					$map[$val] = current($shuffled);
				}

				$cachedObfuscationMap = $map;

				return $map;
			}
		}
	}

	if(!function_exists('dbObfuscate')) {
		function dbObfuscate($str) {
			$map = dbObfuscationMap();
			$obfuscated = '';

			foreach(str_split($str) as $char) {
				if(isset($map[$char]))
					$obfuscated .= $map[$char];
				else
					$obfuscated .= $char;
			}

			return $obfuscated;
		}
	}

	if(!function_exists('dbDecipher')) {
		function dbDecipher($str) {
			$map = dbObfuscationMap();
			$deciphered = '';

			foreach(str_split($str) as $char) {
				$position = array_search((string)$char, $map);
				if($position !== false)
					$deciphered .= $position;
				else
					$deciphered .= $char;
			}

			return $deciphered;
		}
	}

	if(!function_exists('dbDecipherAll')) {
		function dbDecipherAll($data, $fields) {
			$map = dbObfuscationMap();

			foreach($data as $key => $val) {
				if(in_array($key, $fields)) {
					if(!is_null($val)) {
						$deciphered = '';

						foreach(str_split($val) as $char) {
							$position = array_search((string)$char, $map);
							if($position !== false)
								$deciphered .= $position;
							else
								$deciphered .= $char;
						}

						$data[$key] = $deciphered;
					}
				}
			}

			return $data;
		}
	}

	if(!function_exists('dbGetError')) {
		function dbGetError() {
			global $db;

			if(function_exists('mysqli_error'))
				return mysqli_error($db);
			else
				return mysql_error($db);
		}
	}

	if(!function_exists('dbClearCache')) {
		function dbClearCache() {
			$dir = $_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.'sql-cache';

			if(is_dir($dir)) {
				$handler = opendir($dir);

				while ($file = readdir($handler)) {
					if($file != '.' && $file != '..') {
						unlink($dir . DIRECTORY_SEPARATOR . $file);
					}
				}

				closedir($handler);
			}
		}
	}
?>
