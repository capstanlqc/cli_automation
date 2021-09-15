# **IPSOS – workflow automation**

This document outlines the process to automate the creation of the workflow folders and packages for an IPSOS project (other than FLASH).

If you're a PM in a rush to create the workflow (or if you have already read this document once), you can go straight to section [1 How to use the automation: quick steps](#1-how-to-use-the-automation:-quick-steps) below. However, reading the whole document is recommended to understand what you're doing.

The latest version of this document: [https://capps.capstan.be/doc/workflow_automation.php](https://capps.capstan.be/doc/workflow_automation.php). This document must be edited in [github](https://github.com/msoutopico/cli_automation/blob/master/workflow_creation/docs/workflow_automation.md).

#### 0.1 Changes history

| Date  | Person  | Summary |
|---------|---------|-------|
| 12.05.2021 | Manuel | Creation of first version of the document |
| 25.05.2021 | Manuel | Replacing `lll-CCC.txt` with task sheets in the config file |
| 06.09.2021 | Manuel | Simplified and restructured the document to better separate quick steps and detailed info. |
| 15.09.2021 | Manuel | Added information about creating the root folder of the project and scheduling the automation for a new root. |

#### 0.2 Recommended tools:
- [7-zip](https://www.7-zip.org/) for zipping, unzipping and opening packages (without unpacking).
- [Total Commander](https://www.ghisler.com/) for transferring files from one folder to another (especially from server to local and vice versa).
- Notepad (or any other text editor such as [Sublime Text](https://www.sublimetext.com/) or [Atom](https://atom.io/)) to edit text files. DO NOT use Microsoft Word or Wordpad and the like instead of a text editor to edit text files!

#### 0.3 Terminology

You are expected to understand the following concepts: workflow, workflow folder, workflow initiation, configuration file (or config file), initiation bundle (or init bundle), (source) files, (OMT) packages, language tasks, versions, version folders.

In this document, curly braces are used for `{placeholders}`. 

### 04. Preconditions

This document presumes that the root folder of the project already exists. If the root folder of the project doesn't exist yet, it must be created before you can follow the steps below to automate the workflow creation and updates, and it must contain a `02_AUTOMATION` folder (which can be copied from  `u:\IPSOS\_tech\02_AUTOMATION`).

> The FLASH project (see `u:\IPSOS\EUROBAROMETER_FLASH_2.0`) is a good source of inspiration to create a root folder for your project with a neat structure. 

## 1. How to use the automation: quick steps ##

It is the PM's task to prepare both the initiation bundle and maintain the configuration file. 

This document presumes that the root folder of the project already exists. If that's not the case, please see **0.4 Preconditions** above. 

### 1.1. Configuration

Unless there are changes throughout the project, this configuration should be a once-off step. In the config file (location at 2.1 below), do:

1. Review and update the list of languages per task.
    - You may use the [**Locale checker**](https://capps.capstan.be/locale_checker.php) app in cApps to make sure the language codes are correct.
2. Review and update options and parameters.

### 1.2 Adding new root folders to the automation

Please send the path to the root folder of the project to [manuel.souto@capstan.be](manuel.souto@capstan.be) to request scheduling the automation (which by default will run every minute). This path is the value of the "root" parameter in the config file.

> Handover tip for TT: root paths must be added to the file `/media/data/data/company/cApStAn_Tech/20_Automation/Scripts/cli_automation/workflow_creation/paths/roots.txt`.

### 1.3. Workflow initiation

To initiate the workflow (i.e. to create a new workflow folder containing all the necessary subfolders and files), create a new initiation bundle:

1. Copy the initiation bundle template (location at 2.2 below) or the initiation bundle used for a previous workflow, to a local folder in your machine, and unzip it there (or simply open it in 7-zip, if you prefer).
2. If necessary, update the list of subfolders in the version folder template (i.e. `lll-CCC.zip`) under each language task. 
3. Zip again the contents of the initiation bundle (or just close it if you are using 7-zip).
4. Rename the initiation bundle as what you want to call the new workflow (use only letters, numbers and dash, avoid underscore). The name of workflow folder is taken from the init bundle.
5. Copy your new initiation bundle to the `{root}/02_AUTOMATION/Initiation/` folder in the server.

### 1.4. Files 

To create the OMT packages for dispatch:

1. Export the XLIFF files from memoQ or Trados
2. Move them to folder `{root}/05_WORKFLOWS/{workflow}/00_source`

It's also possible to add the XLIFF files to the `00_source` folder of the initiation bundle (steps above) before initiating the workflow to have the packages created at the same time as the workflow folders.

## 2. Workflow and package creation in detail

The root folder of the project (referred here as `{root}` or as the leftmost `/`, full path specified in the config file) contains a folder called `02_AUTOMATION`, which in turn contains folders `Initiation` and `Config`, where the initiation bundle and the config file are expected, respectively.

```
/path/to/project/root
├── 02_AUTOMATION
│   ├── Config
│   │   └── config.xlsx
│   └── Initiation
│       └── {init-bundle}.zip
...
```

The name and location under `{root}` of the `02_AUTOMATION` folder are not customizable. 

### 2.1. Configuration file

The configuration file (or **config file** for short) is available at `{root}/02_AUTOMATION/Config/config.xlsx` and it contains some information that the automation needs to know about the project, e.g. to either find or generate certain files in a certain location with a certain name. 

The configuration file is common for all workflows of the project.

The PM (in consultation with TT) should update the config file whenever there are any changes throughout the project, but it might be left as it is throughout the project if there are no such changes.

The config file contains several worksheets:

| Sheet   | Purpose                                                      |
| :------ | :----------------------------------------------------------- |
| options | You can indicate whether an action must be carried out or not. Please do not rename. |
| params  | A number of parameters (like folder names, package name template, etc.) that might change across projects. Please do not rename. |
| 01_TRA  | The list of versions (cApStAn language codes) for language task `01_TRA` (the sheet name must match the folder for this task in the init bundle). |
| 02_ADA  | The list of versions (cApStAn language codes) for language task `02_ADA` (the sheet name must match the folder for this task in the init bundle). |

There must be one worksheet for each language task. 

The PM can edit this file any time, e.g. to add new rows for new versions to the language task sheets or to change the values of options or parameters.

The lists of language codes in the config file determines what version folders will be created inside the language task folders. Version folders will be created only for language versions included in the config file.

### 2.2. Initiation bundle

The initiation bundle (or **init bundle** for short) is a zipped template of the hierarchy of folders that the workflow folder must contain. It must contain folders `00_source` for the source files and a folder for each language ask (e.g. `01_TRA`, `02_ADA`, etc.).

The `00_source` folder contains an OmegaT package template and a `files` folder, which might contain source files or not.

Each language task folder (e.g. `01_TRA`, `02_ADA`, etc.) in the init bundle must contain one file `lll-CCC.zip` that is a zipped template of the version folder structure to be replicated for each version.

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

If the `00_source/files` folder of the init bundle contains any source files (e.g. memoQ XLIFF files), packages for the corresponding versions will be created at the time of workflow initiation. However, the `00_source/files` folder in the init bundle may be left empty and the PM can add source files to `00_source/files` any time. Packages will only be created if a version folder exists for that language.

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

To create the initiation bundle for a new workflow, the PM can use a template or reuse the init bundle used to create a previous workflow. The template is at `{root}/02_AUTOMATION/Initiation/Templates/init_bundle_template.zip`. Deployed workflows' init bundles are under `{root}/02_AUTOMATION/Initiation/` (or `{root}/02_AUTOMATION/Initiation/_done`, if they are archived).

To initiate the workflow, the init bundle must be put in the folder `{root}/02_AUTOMATION/Initiation/`.

### 2.3. Automated actions

When the initiation bundle is put in the folder `{root}/02_AUTOMATION/Initiation/`,  several things happen: all version folders are created for the specified versions and the OmegaT project packages are created inside them for any source files found in the `00_source` folder.

More in detail:

1. The workflow folder structure is generated:
   - The initiation bundle is deployed in `{root}/08_WORKFLOWS` thereby creating the  workflow folder.
     - It is also archived under `{root}/02_AUTOMATION/Initiation/_done` (in case it needs to be reused).
   - Inside each task folder under the workflow folder, one version folder will be generated for each version in the list of languages specified in the config file, including the contents of the version project template (i.e. `lll-CCC.zip`).
     - The version folder template is archived (for further reference, if needed) under the `_tech` folder inside the task folder.

2. The OMT packages are generated for each version in the folders specified in the config file, including the file(s) for that version found in the `00_source` folder. Packages will be named according to the pattern specified in the config file and should not be renamed.
   - The source files can be added to the `00_source` folder before or after initiating the workflow.

### 2.4 Achtung

Unlike in FLASH, the list of languages for each task is fetched from the config file, not from a `lll-CCC.txt` file.

Unlike in other workflow automations, packages for adaptation are created using source files exported from memoQ, not tweaking packages for a base version.

The list of languages and the source files can be updated at any point. New version folders and new packages will be created accordingly if they don't exist.

## 3. FAQ

##### 3.1. Are packages automatically created when I drop the source files in the `00_source` folder?

Yes, as long as they are named correctly (including the language code that memoQ adds to the file) and as long as the version folder exists for that language version.

##### 3.2. Is the list of language versions updated automatically in the config file when I drop the source files in the `00_source` folder?

No, the list must be updated manually in the config file.

##### 3.3. Will the OMT package be updated automatically if a source file in folder `00_source` is replaced with a newer version? 

No, the package needs to be deleted manually, so that it can be created again with the new source file(s).

##### 3.4. Where does the name of the workflow folder come from?

The workflow folder takes its name from the initiation bundle used to initiate that workflow.

##### 3.5. I can't find the init bundle template. Where is it?

If the root folder of the project already exists, it can be found at `{root}/02_AUTOMATION/Initiation/Templates/`. If the root folder of the project hasn't been created or has just been created but it's not complete, see **0.4 Preconditions** above.
