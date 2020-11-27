#!/usr/bin/php
<?php 

/**
 * This script hides `trans-units` nodes in XLIFF files if they have a specific ID
 *
 * If the translate property is not found, it is added with value "no".
 * If the translate="yes" property is found, value changes to "no".
 * If the translate="no" property is found, nothing is done.
 *
 * @usage:
 * // navigate to the directory contianing the XLIFF files
 * cd path/to/folder
 * // run the script like this:
 * php -f path/to/thisfile.php file.xlf
 * // to run in all files in current directory:
 * for f in $( ls *.xlf ); do php -f /path/to/thisfile.php $f; echo $f; done
 *
 * @author     Mike Wagner <mwagner@ets.org>
 * @version    0.1
 */

$restored_ids = getRestoredIds();
#var_dump($argv[1]);die;
$file = $argv[1];
$text = file_get_contents($file, true);

$doc = new DOMDocument();
$doc->loadXML($text);
$transunits = $doc->getElementsByTagName('trans-unit');
$count = 0;

foreach ($transunits as $tu) {
    foreach($restored_ids as $id) {
        if (preg_match('/'.$id.'/', $tu->getAttribute('id'))) {
            $tu->setAttribute('translate', 'yes');
            $count++;
        }
    }
}

// write the contents back to the file
$doc->formatOutput = true;
$doc->encoding = 'UTF-8';
$doc->save($file, LIBXML_NOEMPTYTAG);
echo $count . " segments have been modified in file \n";

// write the contents back to the file
//file_put_contents($file, $text);


function getRestoredIds() {

    $restored = array(
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+_0",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+_1",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+_2",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+",
        "R547_question01_itemDirections_[0-9a-f]+\.[0-9]+_0",
        "R547_question01_itemDirections_[0-9a-f]+\.[0-9]+_1",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+_0",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+_1",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+_2",
        "R547_question01_itemTitle_[0-9a-f]+\.[0-9]+",
        "R547_question01_itemDirections_[0-9a-f]+\.[0-9]+_0",
        "R547_question01_itemDirections_[0-9a-f]+\.[0-9]+_1",
    );

    return $restored;
}

?>
