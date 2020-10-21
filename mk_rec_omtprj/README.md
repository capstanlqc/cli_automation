# Creating reconciliation packages

This script creates an OmegaT package for a reconciliation task, including the two master TMs that come from the double translation.

## User input

The PM must request the automation of this process, by providing the following information:

* Path of the working folder containing all the version folders (one folder per version)
* The properties for this project (i.e. the name of the folders and files involved) as key-value pairs in a text file

The properties file should be called `proj_props.txt` and should be found in the `_tech` folder, which is at the same level as all the version folders. For example:

```
@Ur:working_directory$
.
├── _tech
│   ├── CONTAINER_lll-CCC.txt
│   ├── lll-CCC.zip
│   └── proj_props.txt
├── ara-ZZZ
│   ├── 00_source
│   ├── 01_translator_1
│   ├── 02_translator_2
│   ├── 03a_to_reconciler
│   ├── 04_etc...
├── ben-IND
│   ├── 00_source
│   ├── 01_translator_1
│   ├── 02_translator_2
...
```

The properties file must have the following structure and keys (only the parts after `=` should be modified, if necessary, e.g. replacing `CONTAINER` with the actual project name, etc.):

    t1_dir=01_translator_1
    t2_dir=02_translator_2
    rec_dir=03a_to_reconciler
    t1_pkg_tmpl=CONTAINER_lll-CCC_OMT_Translator1.omt
    t2_pkg_tmpl=CONTAINER_lll-CCC_OMT_Translator2.omt
    t1_tmx_tmpl=CONTAINER_lll-CCC_Translator1.tmx
    t2_tmx_tmpl=CONTAINER_lll-CCC_Translator2.tmx

A template for the `proj_props.txt` can be downloaded from [here](_tmpl/proj_props.txt).

## Business logic

As a pre-condition, the script will check for the existence and contents of the properties file. If the file is not found or some key is not found in it, the process will stop. Otherwise it will continue.

For each version folder under the working directory, the script will check whether there is a subfolder for reconciliation (i.e. with key `rec_dir` in the properties).
* If there is no such folder, it is assumed that no reconciliation happens for that version and nothing will be done for that version.
* If reconciliation applies for that version, the script will check inside the reconciliation folder whether there is a OMT package there.
    * If there is a OMT package inside the reconcilation subfolder, it is assumed that the package for reconciliation has already been created, and nothing else will be done for that version.
    * If there is no OMT package inside the reconciliation subfolder, the script will check whether there is one OMT package inside the translation 1 subfolder (i.e. with key `t1_dir` in the properties) and one OMT package inside the translation 2 subfolder (i.e. with key `t2_dir` in the properties).
        * If one or both of the translation packages are not found there, nothing else will be done for that version.
        * If the two translation packages are found there, (here comes the real action) the script will create the package for reconciliation under the reconciliation subfolder including the master TMs from each translation.
