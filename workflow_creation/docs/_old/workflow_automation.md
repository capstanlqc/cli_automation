# **IPSOS – Workflow Automation**

This document outlines how the process works and the steps that the PM must take to automate the creation of the workflow folders and packages.

The last version of this document can be read at [https://capps.capstan.be/doc/workflow_automation.php](https://capps.capstan.be/doc/workflow_automation.php).

### Changes history

| Date  | Person  | Summary |
|---------|---------|-------|
| 12.05.2021 | Manuel | Creation of first version of the document |

### Recommended tools:
- [7-zip](https://www.7-zip.org/) for zipping, unzipping and opening packages (without unpacking).
- [Total Commander](https://www.ghisler.com/) for transferring files from one folder to another (especially from server to local and vice versa).
- Notepad (or any other text editor such as [Sublime Text](https://www.sublimetext.com/) or [Atom](https://atom.io/)) to edit text files. DO NOT use Microsoft Word or Wordpad and the like instead of a text editor to edit text files!


### Some requirements

The root folder of the project (referred here as `{root}`) should include a folder called `02_AUTOMATION`. It is when the PM puts the initiation bundle in the `{root}/02_AUTOMATION/Initiation` folder that the process starts to create the folder structure and the translation packages.

### PM's responsibilities

The PM is responsible for taking the following steps:
1. Preparing an initiation bundle that includes all the necessary files (template provided at `{root}/02_AUTOMATION/Initiation/Templates`)
2. Preparing and maintaining up to date a configuration file that includes all the information that the process needs (template provided), located at `{root}/02_AUTOMATION/Config/config.xlsx`
2. Putting the initiation bundle in the initiation folder (i.e. `{root}/02_AUTOMATION/Initiation`)


### Configuration

The configuration file (or config file for short) is available at `/02_AUTOMATION/Config/config.ods` and it contains certain more or less constant pieces of data that the automation needs to know about the project, to either find or generate certain files in a certain location with a certain name.

The PM (in consultation with TT) is responsible for keeping this config file up to date if there are any changes throughout the project, but it might be left as it is throughout the project if there are no such changes.

### Initiation bundle

The initiation bundle must contain folders `00_source`, `10_deliverables` and then one folder for each language task (e.g. TRA, ADA, etc.).

If the process must create the OmegaT project packages too, the `00_source` folder must contain an OmegaT package template and a `files` folder that contains the files (e.g. memoQ XLIFF files).

Each language task folder (e.g. `01_TRA`, `02_ADA`, etc.) must contain one file `lll-CCC.txt` containing the list of languages (one cApStAn language code per line) to which that language task applies and one file `lll-CCC.zip` containing the version folder structure to be replicated for each version.

```
├── 00_source
│   ├── omtpkg_template_paris.omt
│   └── files
│       ├── project_blabla.xlsm_ar.mqxliff
│       └── project_blabla.xlsm_de-AT.mqxliff (etc.)
├── 01_TRA
│   ├── lll-CCC.txt
│   └── lll-CCC.zip
├── 02_ADA
│   ├── lll-CCC.txt
│   └── lll-CCC.zip
└── 10_deliverables
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
5 files
```

An example of the contents of the `lll-CCC.txt` file would be:

```
bul-BGR
ces-CZE
deu-DEU
ell-GRC
esp-ESP
est-EST
fra-FRA
hun-HUN
ita-ITA
pol-POL
slo-SVK
ron-ROU
rus-EST
```

#### Template

A template can be found under `/02_AUTOMATION/Initiation/Templates/init_bundle-template.zip`. It may be used as the basis for the initiation bundle for a new survey translation workflow (after updating the various details to the characteristics of the new survey (e.g. the list of languages for each task, the source MRT file, the bundle's name, etc.), which must be put it in the folder `/02_AUTOMATION/Initiation/` of the project.

**IMPORTANT**: The `lll-CCC.zip` file should include the contents of the version subfolder, not the version subfolder itself. The best way to create the `lll-CCC.zip` file is to simply go into the model `lll-CCC` folder, select all subfolders and zip them, and then rename the zip file created as `lll-CCC.zip` if necessary. Do not zip the `lll-CCC/` folder itself. The same applies to the initiation bundle itself.

#### @PM - Steps to initiate the automation

In a nutshell:

1. Export the XLIFF files from memoQ or Trados for translation and the initiation bundle template from `{root}/02_AUTOMATION/Initiation/Templates/init_bundle-template.zip` to a local folder in your machine.

3. Unzip the initiation bundle template (or simply open it in 7-zip, if you prefer)

3. Put the new files for translation inside the `00_source/files` folder of the initiation bundle.

4. Update the list of languages under each language task folder.
  - Use a text editor to edit the `lll-CCC.txt`.
  - You may use the [**Locale checker**](https://capps.capstan.be/locale_checker.php) app in cApps to make sure the language codes are correct.

5. Zip the contents of the initiation bundle (or just close it if you had simply opened it in 7-zip in step 3).
  - If you zip them, make sure you select the folders and pack them as a new zip file. DO NOT zip the main initiation bundle folder, zip its contents!

6. Rename the initiation bundle as the new workflow/wave name (see above about character restrictions for this name).

7. Copy the new initiation bundle you have created to the `/02_AUTOMATION/Initiation/` folder in the project in the server.

That's it. The process will start, the workflow will be created and, after a couple of minutes, the packages should be ready for dispatch.

----

### Actions triggered

When the initiation bundle is put in the folder `/02_AUTOMATION/Initiation/`,  several things happen within a few minutes: all version folders are created and the OmegaT project packages are created inside them.

More in detail:

Firstly, the survey folder structure is generated:

- The initiation bundle is uncompressed in `{root}/08_WORKFLOWS` thereby creating the  workflow folder.
  - It is also archived under `/02_AUTOMATION/Initiation/_done` (in case it needs to be reused).
- Inside each task folder under the survey folder, one version folder will be generated for each version in the list of languages (i.e. `lll-CCC.txt`) including the contents of the version project template (i.e. `lll-CCC.zip`).
  - The list of languages and the version folder template are archived (for further reference, if needed) under the `_tech` folder inside the task folder.

Secondly, the OMT packages are generated for each version under the `/08_WORKFLOWS/{workflow}/{task}/{version}/01_To_Translator` folder, including the file(s) for that version and named according to the pattern specified in the configuration file. They should not be renamed.

