#!/usr/bin/php
<?php 

/**
 * This script approves `trans-units` nodes in XLIFF files.
 * 
 * If the approved property is not found, it is added with value "yes".  
 * If the approved="no" property is found, value changes to "yes". 
 * If the approved="yes" property is found, nothing is done. 
 *
 * @usage: 
 * // navigate to the directory contianing the XLIFF files
 * cd path/to/folder 
 * // run the script like this: 
 * php -f path/to/hide_dropped_segments.php file.xlf 
 *
 * @author     Mike Wagner <mwagner@ets.org>
 * @version    0.1
 */

#var_dump($argv[1]);die;
$file = $argv[1];
$text = file_get_contents($file, true);

$doc = new DOMDocument();
$doc->loadXML($text);

$transunits = $doc->getElementsByTagName('trans-unit');
foreach ($transunits as $tu) {
	$tu->setAttribute('approved', 'yes');
}

$doc->formatOutput = true;
$doc->encoding = 'UTF-8';
$doc->save($file, LIBXML_NOEMPTYTAG);

?>