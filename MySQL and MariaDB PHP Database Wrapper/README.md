# MySQL / MariaDB PHP Database Wrapper
This is a simple database wrapper written in PHP by QWeb Ltd. Originally built as part of our Egg Basket ecommerce framework in about 2012, it's evolved over the years and is now a part of all of our frameworks.

The built in mysql_ and mysqli_ functions in PHP are combersome. Having to pass handler variables around to arguably difficult to remember function names, and having to first determine whether a server supports the mysqli format, just frustrated me. This wrapper aims to fix these problems, replacing each function with an easier to remember format. Additionally, these functions incorporate a built in cache mechanic, and obfuscation / encryption mechanics important for GDPR compliance.

Should run on just about any PHP server. Tested on LAMP stack.

## Setting Up
- Copy database.php into your project
- Create a new directory in the root of your project tree, named sql-cache
- As early on as possible in your project code, declare the following variables:
```php
$dbHostname = '127.0.0.1'; // The address of your SQL server. PHP running in CLI mode on Linux in a chrooted bash usually requires an IP address here because name resolution isn't always available
$dbDatabase = 'dbFooBah'; // The database name
$dbUsername = 'foobah_usr'; // The database username
$dbPassword = 'Password123'; // The database password
$dbEncryptSeed = 'abcABC123/$' // A string of random mixed case letters, numbers, and symbols unique to each project
```
- And then just load up the wrapper:
```
require_once('path/to/database.php');
```
- The wrapper will immediately take those variables and set up the connection itself, so you can just jump in with SQL calls.
```
require_once('path/to/settings.php'); // It makes sense to declare those variables somewhere central and just load these two files at the beginning of any script that needs database connectivity
require_once('path/to/database.php');

print_r(dbFetchAll(dbQuery('SELECT fldSomething FROM tblSomewhere')));
```

## The functions
The following functions are available within this wrapper:

| Function | Purpose |
| --- | --- |
| dbQuery( string $sql [, int $cacheTime] ) | Executes an SQL query and returns a result handler. If you pass an integer as its optional second parameter, a cache of the result will be created that expires in that number of seconds and this cache will be returned for subsequent identical SQL queries. |
| dbUnbufferedQuery( string $sql ) | Executes an SQL query without waiting for the result. Use for INSERT and UPDATE queries that don't need executing before code continues. |
| dbEscape( string $text ) | Escapes a given string ready for safely injecting into an SQL query. |
| dbGetLastInsertId() | Returns the auto increment ID assigned to the last inserted record. Useful as a follow-up to INSERT queries. E.g. `dbQuery('INSERT INTO tblSomewhere ( fldSomething ) VALUES ( \'Foobah\' )'); $recordID = dbGetLastInsertId();` |
| dbFetch( $recordset ) | Returns the first record in a given recordset as an associative array. This should be used when you only want a single record returned. E.g. `$record = dbFetch(dbQuery('SELECT * FROM tblSomewhere WHERE fldID = 1 LIMIT 1'));` |
| dbFetchAll ( $recordset ) | Returns an associative array of all of the records in a given recordset. The individual records are also associative arrays of their fields. This should be used when you need to iterate each row. E.g. `foreach(dbFetchAll(dbQuery('SELECT fldSomething FROM tblSomewhere')) as $key => $val) { echo $val['fldSomething']."\n"; }` |
| dbNumRows( $recordset ) | Returns the number of records in a given recordset. Useful if you're just testing the data and don't actually need it returning. E.g. `if(dbNumRows(dbQuery('SELECT 1 FROM tblSomewhere WHERE fldSomething = \'foobah\' LIMIT 1')) == 1) { $recordExists = true; }` |
| dbClearQueryCache( string $sql ) | Clears the cache for an individual SQL query. The query must be given exactly as it was when the cache was generated, inclusive of any indentation and spacing used. |
| dbClearCache() | Clears all of the cache files |
| dbEncrypt( string $text ) | Returns a SHA1 hash of a given string, seeded using the defined $dbEncryptSeed variable in both forward and reverse formats for added security. Useful to generate a one-way encryption hash that's reasonably strong enough to be unlikely to decipher. Passwords and such should be stored as encrypted hashes, and lookup strings should be hashed the same way for comparison. E.g. `$sql = dbQuery('SELECT * FROM tblAccounts WHERE fldUsername = \'Foobah\' AND fldPassword = \''.dbEncrypt('Password123').'\' LIMIT 1'); if(dbNumRows($sql) == 1) { $account = dbFetch($sql); }` |
| dbObfuscate( string $text ) | Returns an obfuscated version of a string, using $dbEncryptSeed as part of a charset shuffling algorithm to ensure that the obfuscation differs between projects. The returned string is always the same length as the original and obfuscated in a way that allows for partial string lookups still. E.g. `dbQuery('INSERT INTO tblSomewhere ( fldSomething ) VALUES ( \''.dbEscape(dbObfuscate('This string is stored in obfuscated format')).'\' )'); echo dbNumRows(dbQuery('SELECT 1 FROM tblSomewhere WHERE fldSomething LIKE \'%'.dbEscape(dbObfuscate('stored')).'%\'')).' records found containing the string "stored".';` |
| dbDecipher ( string $text ) | Returns the original string from a given obfuscated format. E.g. `echo dbDecipher(dbFetch(dbQuery('SELECT fldSomething FROM tblSomewhere WHERE fldID = 1 LIMIT 1'))['fldSomething']);` |
| dbDecipherAll( array $record, array $fields ) | Takes a given record, deciphers all of the fields as per the given fields array, and returns a replacement record. Useful when a record contains many obfuscated fields. E.g. `print_r(dbDecipherAll(dbFetch('SELECT * FROM tblSomewhere LIMIT 1'), array('fldSomething', 'fldSomethingElse', 'fldSomeOtherThing')));` |
| dbGetError() | Returns the last generated error as returned by the database engine after a dbQuery() |

## Obfuscation
The dbObfuscate(), dbDecipher(), and dbDecipherAll() functions were designed to offer a way of reasonably obfuscating personal information with minimal impact on performance or engine flexibility. These are relatively basic character shuffling algorithms and don't offer a huge amount in terms of security, but do make it more difficult for anybody with direct access to the database content to know what any particular value is. For good GDPR compliance, all personal information such as names and addresses, contact details, etc should be stored in obfuscated format and deciphered again for output in the relevant parts of a project, where access is already restricted to authorised parties via login forms for example.

It's important to note that dbObfuscate(), dbDecipher(), and dbDecipherAll() all use the defined $dbEncryptSeed variable for creating a shuffled character map, so if this variable is changed after data has been obfuscated, neither dbDecipher() nor dbDecipherAll() will be able to properly decipher it again. dbObfuscate() and dbEncrypt() will also create different hashes so lookups won't work properly either. This also means that data obfuscated by one project cannot easily be deciphered by another project, even though they share the same code. In a nutshell, you should always set a different $dbEncryptSeed with every project that uses this wrapper, and you should never change this value after the initial set-up.

## Cache
The cache mechanic offers a way of dumping recordsets to plain text files for faster subsequent lookups. This can be useful in taking the strain away from a database engine during peak traffic, at the cost of increasing the physical size of a website on disk.

It's good practice to use cache for as many SELECT queries as possible, and to call dbClearCache() after any INSERT or UPDATE queries. Even a 1 second cache can make a huge difference if a particular query takes 0.2 seconds to process and is called on every page load on a website that's hit with multiple requests per second. It's better practice to dump a longer living cache of that same query and fire a dbClearCache() any time the data it's returning has been updated.

The cache files are dumped to a root level folder named sql-cache . If you have cron scripts running in CLI mode then the natural root folder for those might differ to the root httpdocs of the website itself. In which case, within such CLI scripts, before loading up database.php you should set the document root to match the httpdocs folder. For example, if your website is in /httpdocs and your CLI script is running from /httpdocs/scripts, you could do this:

```
$_SERVER['DOCUMENT_ROOT'] = $_SERVER['PWD'].DIRECTORY_SEPARATOR.'..'.DIRECTORY_SEPARATOR;
require_once('path/to/settings.php');
require_once('path/to/database.php');
```

Or, if your website is in /httpdocs and your CLI script is running from /crons, you could do this:

```
$_SERVER['DOCUMENT_ROOT'] = $_SERVER['PWD'].DIRECTORY_SEPARATOR.'..'.DIRECTORY_SEPARATOR.'httpdocs'.DIRECTORY_SEPARATOR;
require_once('path/to/settings.php');
require_once('path/to/database.php');
```

## Support
I'm an advocate of open source, FOSS, FSF, and such. Like all other scripts and tools within this repository, this code is provided for free in the hopes it's useful to somebody. If you found this helpful and want to show your support, donations are always greatly appreciated.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N1GXJ1U)
