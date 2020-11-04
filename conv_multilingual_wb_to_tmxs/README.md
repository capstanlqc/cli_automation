# Convert multilingual workbook to multiple TMX files [task 20.3000]

Input: multilingual spreadsheet
Ouput: one TMX file per language pair

This script converts the multilingual workbook into as many TMX files as target languages (or language pairs) it contains.

TODO:
* remove markup (TBC by you!)
* segment the cells whenever possible

The utility is not a webapp (but will be part of cApps if necessary — if requests like this abound). For the time being the PM needs to send the request by email and I run the thing on demand. If I happen not to be available, Adrien could run it too in the server.

The first worksheet in the workbok must be called `config` and include the following options, to be updated by the PM.


| KEY                    | VALUE                            | DESCRIPTION |
|:--------------------	|:-------------------------------	|:-------------	|
| container           	| ECS                            	| String: Add the the name of the actual container (case-sensitive). It needs to exist in the containers manager.                                                                                                                                                                                                                      |
| source_lang         	| eng-ZZZ                        	| String: Include if not English.                                                                                                                                                                                           |
| tmx_file_names         | `<container>`, `<target_lang>`, `TM` | List of strings: List all elements that should be included in the name of the TMX   files. Container must be the first one and they must appear in order   (separated by commas). Placeholders (e.g. `<this>`) refer to keys in   this config sheet (first column). All elements in this list will be joined   with underscore, e.g. `<container>_<xxx-XXX>_TM.tmx`. If you want   to include word "QQ" between container and language, this cell   should contain [`<container>, QQ, <target_lang>, TM`] (without   the square brackets), and that will produce   `<container>_QQ_<xxx-XXX>_TM.tmx`.                                                                                                                                                                                                   |
| segmentation           | yes                              | Boolean: Contents of cells will be segmented if possible (if the same number of   sentences, line breaks, etc. Is found on both languages)                                                                                                                                                                                                    |
| remove_html_tags       | yes                              | Boolean: Parts of the text matched by `<[^>]+>` will be removed.                                                                                                                                                   |
| remove_linebreaks      | no                               | Boolean: Linebreaks (i.e. `[^\r\n]+`) will be removed withing translation units.                                                                                                                                  |
| remove_multiple_spaces | no                               | Boolean: Double or multiple normal spaces will be replaced by one single space.                                                                                                                                   |
| remove_pattern         |                                  | Regex: Parts of the text matched by this expression will be removed.So for example   if you wanted to have parts like “[[Privacy_Policy.ENG.pdf\|προστασία της   ιδιωτικής ζωής]]” or "((*\|Meetings include online meetings))"   removed, the remove pattern should be something like `\[\[[^\]]+\]\]` or   `\(\([^)]+\)\)`, respectively. You (or the PM) don’t have to write that, you   can just provide examples and an explanation.                                                                                                                                                             |
| ofuscate_pattern       |                                  | Regex: Parts of the text matched by this expression will be ofuscated, e.g. Xxxxxx                                                                                                                                |
| ignore_cell_pattern    |                                  | Regex: Cells matched by this expression will not be included in the TMX file.                                                                                                                                     |
| header_row             | 0                                | Integer: Indicate the row containing the language codes. Starts with index 0 (row 1).                             |
| comment_column         |                                  | Letter or string: Indicate whether any column contains a comment or description that   should be included in every translation unit. Add letter name of the column   or exact text content of the cell at the `header_row`.                                                                                                                   |

Workbook template: [multilingual_tmwb_template.xlsx](multilingual_tmwb_template.xlsx)

    I will document the process and make available a template of spreadsheet for this automation. For the time being, simply review these options, and if you want to change any, please update the file in the server. No need to make a new copy of the file.
