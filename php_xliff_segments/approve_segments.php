#!/usr/bin/php
<?php 

// navigate to the directory contianing the XLIFF files
## cd path/to/folder
// run the script like this: 
## php -f path/to/approved_segments.php file.xlf 
// to do it in all files in the directory (in the linux terminal):
## for f in $( ls ); do php -f /mnt/c/Users/manuel/Dropbox/Scripts/PHP/approve_segments.php $f; done

// in PowerShell, if you install PHP with chocolatey, it can be run like (for all files in the current directory):
## Get-ChildItem -File | Foreach {php -f C:\Path\To\approve_segments.php $_.fullname}

// get second argument (file)
$file = $argv[1];
// extract text from file
$text = file_get_contents($file, true);

// add approved="yes" to a trans-unit node if not found
$text = preg_replace('/(<trans-unit (?!.*?approved).*)\K(?=>)/', ' approved="yes"', $text);
// turn approved="no" to "yes" in a trans-unit if 
$text = preg_replace('/<trans-unit [^>]+\Kapproved="no"/', 'approved="yes"', $text);

// write the contents back to the file
file_put_contents($file, $text);

?>