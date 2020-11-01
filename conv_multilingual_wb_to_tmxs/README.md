# Task 20.3000

Input: multilingual spreadsheet
Ouput: one TMX file per language pair

This script converts the multilingual workbook into as many TMX files as target languages (or language pairs) it contains. 

TODO: 
* emove markup (TBC by you!)
* segment the cells whenever possible

The utility is not a webapp (but will be part of cApps if necessary — if requests like this abound). For the time being the PM needs to send the request by email and I run the thing on demand. If I happen not to be available, Adrien could run it too in the server.

The first worksheet in the workbok must be called `config` and include the following options, to be updated by the PM. 

| key                   | value                           | description            |
|:--------------------	|:-------------------------------	|:-------------	|
| container           	| ECS                            	| Add the the name of the actual container (case-sensitive). It needs to exist in the containers manager.  	|
| source_lang         	| eng-ZZZ                        	| Include if not English.                     	|
| tmx_file_names      	| `<container>`, `<target_lang>`, `TM` 	| List all elements that should be included in the name of the TMX files. Container must be the first one and they must appear in order (separated by commas). Placeholders (e.g. <this>) refer to keys in this config sheet (first column). All elements in this list will be joined with underscore, e.g. `<container>_<xxx-XXX>_TM.tmx`. If you want to include word "QQ" between container and language, this cell should contain [`<container>`, `QQ`, `<target_lang>`, `TM`] (without the square brackets), and that will produce `<container>_QQ_<xxx-XXX>_TM.tmx`. 	|
| segmentation        	| yes                            	| Contents of cells will be segmented if possible (if the same number of sentences, line breaks, etc. Is found on both languages)             	|
| remove_html_tags    	| yes                            	| Parts of the text matched by `<[^>]+>` will be removed.           	|
| remove_pattern      	|                                	| Parts of the text matched this expression will be removed.     	|
| ignore_cell_pattern 	|                                	| Cells matched by this expression will not be included in the TMX file.     	|
| header_row          	| 0                              	| Indicate the row containing the language codes. Starts with index 0 (row 1).          	|
| comment_column      	|                                	| Indicate whether any column contains a comment or description that should be included in every segment pair.    	|




    I will document the process and make available a template of spreadsheet for this automation. For the time being, simply review these options, and if you want to change any, please update the file in the server. No need to make a new copy of the file.
