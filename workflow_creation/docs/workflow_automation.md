# **IPSOS – Workflow Automation**

This document outlines how the process works and the steps that the PM must take to automate the creation of the workflow folders and packages.

The last version of this document can be read at [https://capps.capstan.be/doc/workflow_automation.php](https://capps.capstan.be/doc/workflow_automation.php).

### Changes history

| Date  | Person  | Summary |
|---------|---------|-------|
| 12.05.2021 | Manuel | Creation of first version of the document |
| 25.05.2021 | Manuel | Replacing lll-CCC.txt with task sheets in the config file |

### Recommended tools:
- [7-zip](https://www.7-zip.org/) for zipping, unzipping and opening packages (without unpacking).
- [Total Commander](https://www.ghisler.com/) for transferring files from one folder to another (especially from server to local and vice versa).
- Notepad (or any other text editor such as [Sublime Text](https://www.sublimetext.com/) or [Atom](https://atom.io/)) to edit text files. DO NOT use Microsoft Word or Wordpad and the like instead of a text editor to edit text files!


### Some requirements

The root folder of the project (referred here as `{root}`) contains a folder called `02_AUTOMATION`, which in turn contains folders `Initiation` and `Config`, where the initiation bundle and the config file are expected, respectively.

```
/path/to/project/root
├── 02_AUTOMATION
│   ├── Config
│   │   └── config.xlsx
│   └── Initiation
│       └── [init-bundle].zip
...
```

The name and location of the `02_AUTOMATION` fodler are not customizable. 

### Characteristics of the workflow

The initiation bundle is a zipped template of the hierarchy of folders for the workflow, and inside each language task, it contains a zipped templated of each version folder.

Packages for adaptation are created using source files exported from memoQ, not tweaking base packages for another version.

The list of languages for each task is fetched from the config file, not from a `lll-CCC.txt` file.

The list of languages and the source files can be updated at any point. New version folders and new packages will be created accordingly. 


### PM's responsibilities

The PM is responsible for taking the following steps:
1. Preparing an initiation bundle that includes all the necessary files (template provided at `{root}/02_AUTOMATION/Initiation/Templates`)
2. Preparing and maintaining up to date a configuration file that includes all the information that the process needs (template provided), located at `{root}/02_AUTOMATION/Config/config.xlsx`
2. Putting the initiation bundle in the initiation folder (i.e. `{root}/02_AUTOMATION/Initiation`)


### Configuration

The configuration file (or config file for short) is available at `/02_AUTOMATION/Config/config.xlsx` and it contains certain more or less constant pieces of data that the automation needs to know about the project, to either find or generate certain files in a certain location with a certain name.

The PM (in consultation with TT) is responsible for keeping this config file up to date if there are any changes throughout the project, but it might be left as it is throughout the project if there are no such changes.

The config file contains several worksheets:

| Sheet     | Purpose   | 
| :--------- | :--------- |
| options | You can indicate whether an action must be carried out or not. |
| params  | A number of parameters (like folder names, package name template, etc.) that might change across projects. |
| 01_TRA  | The list of versions (cApStAn language codes) for task 01_TRA (the sheet name must match the folder for this task in the init bundle). |
| 02_ADA  | The list of versions (cApStAn language codes) for task 02_ADA (the sheet name must match the folder for this task in the init bundle). |

The PM can edit this file any time, e.g. to add new rows for new versions to the task sheets.

### Initiation bundle

The initiation bundle must contain folders `00_source` for the source files and a folder for each language ask (e.g. TRA, ADA, etc.).

If the process must create the OmegaT project packages too, the `00_source` folder must contain an OmegaT package template and a `files` folder that contains the source files (e.g. memoQ XLIFF files).

The PM can add new source files to `00_source/files` any time.

Each language task folder (e.g. `01_TRA`, `02_ADA`, etc.) must contain one file `lll-CCC.zip` containing the version folder structure to be replicated for each version.

```
workflow:
├── 00_source
│   ├── omtpkg_template_paris.omt
│   └── files
│       ├── project_blabla.xlsm_ar.mqxliff
│       └── project_blabla.xlsm_de-AT.mqxliff (etc.)
├── 01_TRA
│   └── lll-CCC.zip
└── 02_ADA
    └── lll-CCC.zip
```

####  Examples

An example of `lll-CCC.zip` file would be:

```
Archive:  lll-CCC.zip
Name
----
01_To_Translator
02_From_Translator
03_From_Verifier
04_Verif_Review
05_Machine_Translation
-------
5 folders
```

#### Template

A template can be found under `/02_AUTOMATION/Initiation/Templates/init_bundle_template.zip`. It may be used as the basis for the actual initiation bundle for a new workflow, which must be put it in the folder `/02_AUTOMATION/Initiation/` of the project.

#### @PM - Steps to initiate the automation

In a nutshell:

1. Update the list of languages and the other options and parameters in the config file.
    - You may use the [**Locale checker**](https://capps.capstan.be/locale_checker.php) app in cApps to make sure the language codes are correct.
  
1. Export the XLIFF files from memoQ or Trados for translation to a local folder in your machine.

3. Copy the initiation bundle template (available at `{root}/02_AUTOMATION/Initiation/Templates/init_bundle_template.zip` ) to a local folder in your machine and unzip it (or simply open it in 7-zip, if you prefer).

3. Put the new files for translation inside the `00_source/files` folder of the initiation bundle.

4. If necessary, update the list of subfolders in the `lll-CCC.zip` bundle under each language task.

5. Zip the contents of the initiation bundle (or just close it if you had simply opened it in 7-zip in step 3).

6. Rename the initiation bundle as what you want to call the new workflow/wave (use only letters, numbers and dash, avoid underscore).

7. Copy the new initiation bundle you have created to the `{root}/02_AUTOMATION/Initiation/` folder in the project in the server.

That's it. The process will start, the workflow will be created and, after a couple of minutes, the packages should be ready for dispatch.

----

### Actions triggered

When the initiation bundle is put in the folder `{root}/02_AUTOMATION/Initiation/`,  several things happen within a few minutes: all version folders are created for the specified versions and the OmegaT project packages are created inside them for the source files found.

More in detail:

Firstly, the survey folder structure is generated:

- The initiation bundle is uncompressed in `{root}/08_WORKFLOWS` thereby creating the  workflow folder.
  - It is also archived under `/02_AUTOMATION/Initiation/_done` (in case it needs to be reused).
- Inside each task folder under the survey folder, one version folder will be generated for each version in the list of languages (i.e. `lll-CCC.txt`) including the contents of the version project template (i.e. `lll-CCC.zip`).
  - The list of languages and the version folder template are archived (for further reference, if needed) under the `_tech` folder inside the task folder.

Secondly, the OMT packages are generated for each version under the `/08_WORKFLOWS/{workflow}/{task}/{version}/01_To_Translator` folder, including the file(s) for that version and named according to the pattern specified in the configuration file. They should not be renamed.


