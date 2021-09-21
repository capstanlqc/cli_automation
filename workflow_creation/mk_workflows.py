#!/usr/bin/env python3

#  This file is part of cApps.
#
#  This script is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with cApps.  If not, see <https://www.gnu.org/licenses/>.

# pipenv install --python 3.9.1
# call it from cron as: every 5 min, pipenv run python3 mk_workflows.py -i /path/to/init/bundle -c /path/to/config/file -m /path/to/mapping/file (memoq_capstan_mapping_20210512.xlsx)

# ############# AUTHORSHIP INFO ###########################################

__author__ = "Manuel Souto Pico"
__copyright__ = "Copyright 2021, cApps/cApStAn"
__credits__ = ["Manuel Souto Pico"]
__license__ = "GPL"
__version__ = "0.1.0"
__maintainer__ = "Manuel Souto Pico"
__email__ = "manuel.souto@capstan.be"
__status__ = "Testing / pre-production" # "Production"

# ############# IMPORTS ###########################################

import sys, os, shutil, pwd, grp
import time
import logging
import pathlib
from shutil import copyfile
import pandas as pd
import argparse
from zipfile import ZipFile
from pathlib import Path
from common import delete_folder
import wget
import collections
from common import remove_from_zip
from common import add_files_to_zip
import fstr
import subprocess
# from pandas_ods_reader import read_ods
# from pprint import pprint
# import zipfile
# from glob import glob
import requests
import json
import posixpath
import ntpath
import re

# ############# PROGRAM DESCRIPTION ###########################################

text = "This application automates the creation of workflow folders and creates OmegaT project packages"

# intialize arg parser with a description
parser = argparse.ArgumentParser(description=text)
parser.add_argument("-V", "--version", help="show program version", action="store_true")
parser.add_argument("-i", "--input", help="specify path to input file (init bundle)")
parser.add_argument("-m", "--mapping", help="specify path to mapping file, to know correspondence between different \
                                            language codes")
parser.add_argument("-c", "--config", help="specify path to config file")


# read arguments from the command line
args = parser.parse_args()

# check for -V or --version
if args.version:
    print(f"This is the workflow creation utility, version {__version__}")
    sys.exit()

if args.input and args.mapping and args.config:
    init_path = Path(args.input.rstrip('/'))
    mapping_path = Path(args.mapping.rstrip('/'))
    config_path = Path(args.config.rstrip('/'))
else:
    print("Arguments -i or -m or -c not found.")
    sys.exit()


# ############# LOGGING ###########################################

ts = time.localtime()
# the directory of this script being run (e.g. /path/to/cli_automation/flash_prepp_help)
parent_dir_abspath = pathlib.Path(__file__).parent.absolute()
# current working directory (from where the script is called )
# y = pathlib.Path().absolute()

logdir_path = os.path.join(parent_dir_abspath, '_log')
try:
    os.mkdir(logdir_path)
except OSError:
    pass
    # print("Directory %s was not created, presumably it already existed." % logdir_path)
else:
    print("Successfully created the directory %s " % logdir_path)

formatted_ts = time.strftime("%Y%m%d_%H%M%S", ts)
logfile_path = os.path.join(logdir_path, formatted_ts + '.log')
# open(log_fname, "a")
print(f"The log will be printed to '{logfile_path}'")

logging.basicConfig(format='[%(asctime)s] %(name)s@%(module)s:%(lineno)d %(levelname)s: %(message)s',
                    filename=logfile_path, level=logging.DEBUG) # encoding='utf-8' only for >= 3.9
logging.captureWarnings(True)

# ############# FUNCTIONS ###########################################


def update_docs():
    # # todo: turn this around -> upload the file to upload_doc.php
    # # https://stackabuse.com/how-to-upload-files-with-pythons-requests-library/
    # fname = 'workflow_automation.md'
    # docs_dir_path = os.path.join(parent_dir_abspath, 'docs')
    # doc_path = os.path.join(docs_dir_path, fname)
    # if Path(doc_path).exists():
    #     logging.info(f"doc_path: {doc_path} exists")
    #     os.remove(doc_path)
    # url = 'https://capps.capstan.be/doc/md/workflow_automation.md'
    # wget.download(url, docs_dir_path)

    filename = "workflow_automation.md"
    file = os.path.join(parent_dir_abspath, "docs", filename)
    with open(file, 'rb') as f:
        r = requests.post('https://capps.capstan.be/doc/upload_md.php', data = {"submit": "submit"}, files={'test2.md': f})

        r = json.loads(r.text)
    if r['status'] != "ok":
        logging.error(f"Could not publish document '{filename}'.")


def get_boolean_value(x):
    """ Convert loose human booleans to proper booleans """
    return x if isinstance(x, bool) \
        else True if x.strip().lower() in ['true', '1', 'y', 'yes', 1] \
        else False


def get_col_from_ws(config_file_path, sheet_name, use_col):  # rewrite: input is sheet_df, not file
    """ Gets list of values from specific worksheet """
    if config_file_path.exists():
        df = pd.read_excel(config_file_path, sheet_name=sheet_name, usecols=use_col)
        return df['version'].values.tolist()
    else:
        logging.error("The config file does not exist")
        return None


def get_colpair_from_ws(config_file_path, sheet_name, use_cols):  # rewrite: input is sheet_df, not file
    """ Gets list of key-value pairs from specific worksheet """
    if config_file_path.exists():
        x, y = use_cols[0], use_cols[1]
        df = pd.read_excel(config_file_path, sheet_name=sheet_name, usecols=use_cols)
        return dict(zip(df[x], df[y]))
    else:
        logging.error("The config file does not exist)")
        return None


def instantiate_fname_from_template(string, **kwargs):
    """ Turns filename template into actual filename instance. """
    for key in kwargs:
        # to extract optional arguments
        vars()[key] = kwargs[key]  # equivalent to version = kwargs[key] when key = 'version'
    if '{' in string:
        template = fstr(string)
        return template.evaluate()
    else:
        return string


def strip_file_extension(filename):  # or filepath
    """ Returns the name of the file without the extension.
        The filename can have dots. """
    return os.path.splitext(filename)[0]


def unpack_bundle(bundle, location):
    """ Deploys initiation bundle to create workflow folder """
    # Create a ZipFile Object and load sample.zip in it
    unpacked_bundle_path = os.path.join(location, os.path.basename(bundle))
    # if Path(unpacked_bundle_path).exists....
    if overwrite_folders:
        delete_folder(unpacked_bundle_path)  # @test // add new folders??

    if not os.path.exists(unpacked_bundle_path):
        #os.makedirs(file_path) # creates with default perms 0777
        #os.umask(0)
        #os.makedirs(unpacked_bundle_path, mode=0o777)
        os.system(f"chgrp -R users {location}")
        with ZipFile(bundle, 'r') as zipObj:
            # ZipFile.extractall(path=None, members=None, pwd=None)
            # Extract all the contents of zip file in directory 'location'
            zipObj.extractall(location)

        
        #subprocess.call(['chown', '-R', 'manuel:"BOSVOORDE\Domain Users"', 'dir'])


def get_versions_for_task(task):
    """ Gets list of cApStAn language codes for the language task """
    try:
        logging.debug("Let's try to open the language list file")
        return get_col_from_ws(config_path, sheet_name=task, use_col=['version'])  # list
    except Exception as e:
        logging.error(f"I couldn't get list of versions from config file: {e}")
        return None


def create_version_folders(versions, dir_templ_path, dirpath):
    """ For each version unpack dir_templ_path in dirpath, returns list of paths to folders created. """
    paths = []
    try:
        if versions:
            for ver in versions:
                version_dir_path = os.path.join(dirpath, ver)
                paths.append(version_dir_path) # for log
                unpack_bundle(dir_templ_path, version_dir_path)
        return paths
    except Exception as e:
        logging.error(f"Could not create version folders: {e}")
        return None


def archive_tech_files(dirpath, files):
    """ Archives template and list """
    tech_path = os.path.join(dirpath, '_tech')

    if not Path(tech_path).exists():
        os.mkdir(tech_path)

    for f in files:
        fpath = os.path.join(dirpath, f)
        if Path(fpath).exists():
            shutil.move(fpath, os.path.join(tech_path, f))


def build_2langtag_mapping_from_csv(mapping_path, use_cols):  # not used
    """ Creates a dictionary with all the langtag pairs available.
        use_cols must be a two-item list, e.g. use_cols = ['cApStAn', 'BCP47'] """
    # mapping = get_df_from_xlsx(mapping_path, sheet_name=None)
    map_df = pd.read_csv(mapping_path, usecols=use_cols)
    x, y = use_cols
    mq2caps_langtag_mapping = dict(zip(map_df[x], map_df[y]))
    return mq2caps_langtag_mapping


def build_2langtag_mapping(path_to_mapping_file, use_cols, sheet_name=None):
    """ Creates a dictionary with all the langtag pairs available.
        use_cols must be a two-item list, e.g. use_cols = ['cApStAn', 'BCP47'] """
    if sheet_name:  # and path_to_mapping_file ends with xslx
        # mapping = get_df_from_xlsx(path_to_mapping_file, sheet_name=None)
        map_df = pd.read_excel(path_to_mapping_file, usecols=use_cols, sheet_name=sheet_name)
    else:  # elif path_to_mapping_file ends with csv
        # read_csv
        map_df = pd.read_csv(path_to_mapping_file, usecols=use_cols)

    x, y = use_cols
    return dict(zip(map_df[x], map_df[y]))  # todo: skip nan


def get_langtag_from_fname(src_file, langtags):
    if any(tag in src_file for tag in langtags):
        tags = [tag for tag in langtags if(tag in src_file)]
        return max(tags, key=len)  # returning the longest code found (dut-NL, not dut)
    else:
        return None


def get_omtpkg_template_path(wrkflw_dir_path):

    for dirpath, dirnames, files in os.walk(wrkflw_dir_path):
        # under 00_source
        if dirpath.endswith('00_source') and any(f.endswith(".omt") for f in files) and 'files' in dirnames:

            logging.info(f"OmegaT project package template found")
            omtpkg_template_fname = [f for f in files if(f.endswith(".omt"))][0]  # gets the 1st one, only 1 is expected
            return os.path.join(dirpath, omtpkg_template_fname)


def get_files_per_version(wrkflw_dir_path):
    # iles_per_version = dict.fromkeys(versions, [])
    files_per_version = collections.defaultdict(list)  # values will be lists

    for dirpath, dirnames, files in os.walk(wrkflw_dir_path):
        # under 00_source
        if files and any(f.endswith(".omt") for f in files) and 'files' in dirnames and dirpath.endswith('00_source'):

            src_files_dir = os.path.join(dirpath, 'files')
            logging.info(f"Source files found: {os.listdir(src_files_dir)}")

            for src_file in os.listdir(src_files_dir):

                logging.info(f"------------------")
                # logging.info(f"Adding file {src_file} to the project package")
                logging.info(f"Getting language from file {src_file}")
                tag = get_langtag_from_fname(src_file, mq_langtags)
                

                if tag:
                    logging.info(f"File has BCP47 tag {tag}")
                    capstan_langcode = mq2caps_langtag_mapping[tag]
                    logging.info(f"Version has cApStAn code {capstan_langcode}")

                    logging.info(f"Assigning {src_file} to version {capstan_langcode}")
                    files_per_version[capstan_langcode].append(os.path.join(src_files_dir, src_file))
                else:
                    logging.warning("No language tag found in the file name.")

            logging.info("---------------------") # 

    # todo: add_missing_versions_based_on_srcfiles(files_per_version.keys())
    # to lll-CCC.txt in _tech and to the init bundle in _done
    return files_per_version


def do_update_langtag_in_prj_settings(omtpkg_instance_path, capstan_langcode):
    """ Replaces xx-XX in the project settings with the actual OmegaT (4) language tag."""

    logging.info(f"Let's instantiate the BCP47 language tag in the project settings.")
    omegat4_tag = caps2ot4_langtag_mapping[capstan_langcode]
    logging.info(f"Project settings should have {omegat4_tag} instead of 'xx-XX'.")

    logging.info("Extracting 'omegat.project'")
    version_temp_dir = f'_temp/{capstan_langcode}'
    with ZipFile(omtpkg_instance_path, 'r') as omtpkg:
        omtpkg.extract('omegat.project', version_temp_dir) # file to extract, dir where to extract

    logging.info("Updating 'omegat.project' outside of the package")
    omtprj_settings_tempfile = os.path.join(version_temp_dir, 'omegat.project')
    with open(omtprj_settings_tempfile, 'r+') as f:
        text = f.read()
        # text = re.sub('xx-XX', omegat4_tag, text)
        text = text.replace('xx-XX', omegat4_tag)
        f.seek(0)
        f.write(text)
        f.truncate()

    logging.info("Removing generic 'omegat.project' from package.")
    files_to_remove = "omegat.project", #tuple
    remove_from_zip(omtpkg_instance_path, *files_to_remove) # tuple

    logging.info("Adding updated 'omegat.project' to package")
    with ZipFile(omtpkg_instance_path, "a" ) as omtpkg:
        omtpkg.write(omtprj_settings_tempfile, f'omegat.project')

    delete_folder(version_temp_dir)


def do_create_omtpkg_instances(wrkflw_dir_path, files_per_version, omtpkg_templ_path, task_dirs):
    """ Tries to create the OMT packages inside the folders to translators and add the source files to each pacakge. """

    logging.info(f'---------------------')
    logging.info(f'Double translation: {double_xlat}')
    try:
        logging.info(f'---------------------')
        logging.info(f"Let's try to create the OMT project packages")
        for dirpath, children_dirs, children_files in os.walk(wrkflw_dir_path):
            # print(f'dirpath: {dirpath} \child_dirs: {children_dirs} \child_files: {children_files}\n------------\n')

            for capstan_langcode, src_files in files_per_version.items():  # xxx-XXX => paths

               #logging.debug(f'{task_dirs=}')
                if dirpath.endswith(capstan_langcode) and task_dirs[0] in children_dirs:

                    for (i, toVendor_dir) in enumerate(task_dirs, start=1):
                        logging.debug(f'{toVendor_dir=}')
                        toVendor_dir_path = os.path.join(dirpath, toVendor_dir)
                        omtpkg_instance_name = instantiate_fname_from_template(params['omtpkg_name_template'],
                                                                               version=capstan_langcode)
                        if double_xlat and len(task_dirs) == 2: # if length 2 means it's creating the two packages for the translators
                            omtpkg_instance_name = omtpkg_instance_name.replace('_OMT.omt', f'_T{i}_OMT.omt')

                        logging.info(f'---------------------')
                        logging.info(f"Creating package {omtpkg_instance_name} in {toVendor_dir_path}")
                        logging.info(f"The new project package will be called {omtpkg_instance_name}")
                        omtpkg_instance_path = os.path.join(toVendor_dir_path, omtpkg_instance_name)
                        logging.info(f"The new project package will have path {omtpkg_instance_path}")

                        if overwrite_packages or not Path(omtpkg_instance_path).exists():
                            logging.info(f"Creating {omtpkg_instance_path}.")
                            copyfile(omtpkg_templ_path, omtpkg_instance_path)  # only accepts strs, use os.path.copy
                            # edit project's language tag

                            do_update_langtag_in_prj_settings(omtpkg_instance_path, capstan_langcode)
                            # do_add_srcfiles_to_prjpkg(omtpkg_instance_path, src_files)  # rm fn
                            add_files_to_zip(omtpkg_instance_path, src_files, 'source')

                        else:
                            logging.warning(f"Package {omtpkg_instance_name} will NOT be created (either it already exists or option 'overwrite_folders' is not set).")
                    
    except Exception as e:
        logging.error(f"Unable to create (some of the) OMT package instances: \n {e}.")


def do_deploy_workflow(wrkflw_dir_path):
    """ Deploy the contents (folders and files) inside the main workflow folder """
    logging.debug("Logging from function do_deploy_workflow()")
    for dirpath, children_dirs, children_files in os.walk(wrkflw_dir_path):
        #logging.debug(f'{dirpath=}')
        #logging.debug(f'{children_dirs=}')
        #logging.debug(f'{children_files=}')
        # under the language task folders
        if children_files and 'lll-CCC.zip' in children_files and not dirpath.endswith('_tech'):
            task = os.path.basename(dirpath)
            logging.debug(f"{task=}")
            dir_templ_path = os.path.join(dirpath, 'lll-CCC.zip')
            logging.debug(f"{dir_templ_path=}")
            versions = get_versions_for_task(task)
            # todo: add versions to _tech/lll-CCC.txt
            logging.debug(f"{versions=}")
            folders_created = create_version_folders(versions, dir_templ_path, dirpath)
            logging.debug(f"{folders_created=}")
            if folders_created:
                archive_tech_files(dirpath, ['lll-CCC.zip', 'lll-CCC.txt', 'ada_lang_mapping.ods'])
        # under the _tech folder after the workflow has been initialized but new folders have been added
        elif children_files and 'lll-CCC.zip' in children_files and dirpath.endswith('_tech'):
            task = os.path.basename(os.path.dirname(dirpath))
            logging.debug(f"{task=}")
            logging.debug(f"{dirpath=}")
            logging.debug(f"Let's see whether new versions have been added after initializing the workflow...")
            dir_templ_path = os.path.join(dirpath, 'lll-CCC.zip')
            logging.debug(f"{dir_templ_path=}")
            versions = get_versions_for_task(task)
            logging.debug(f"{versions=}")
            folders_created = create_version_folders(versions, dir_templ_path, os.path.dirname(dirpath))
            logging.debug(f"{folders_created=}")
            logging.debug(f"..............................")


def get_path_of_1st_omt_in_dir(path_to, parent_dir):
    parent_dir_path = os.path.join(path_to, parent_dir)
    try:
        from_xlat_omt = [f for f in os.listdir(parent_dir_path) if str(f).endswith('.omt')][0]
        return os.path.join(parent_dir_path, from_xlat_omt)
    except Exception as e:
        print(f"Unable to get path of first OMT file in directory {parent_dir_path}, exception: {e}")
        return None


def extract_internal_tm(dirpath, from_xlat_dir):
    """ Extract the internal TM (project_save) from package and returns path to the tmx file. """

    from_xlat_omt_path = get_path_of_1st_omt_in_dir(dirpath, from_xlat_dir)
    from_xlat_omt = os.path.basename(from_xlat_omt_path)

    if from_xlat_omt_path:
        temp_dir = '_temp'
        with ZipFile(from_xlat_omt_path, 'r') as omtpkg:
            omtpkg.extract('omegat/project_save.tmx', temp_dir)  # file to extract, dir where to extract

        tmx_path = os.path.join(temp_dir, 'omegat', 'project_save.tmx')
        tmx_newname = str(from_xlat_omt).replace('.omt', '')
        new_tmx_path = str(tmx_path).replace('project_save', tmx_newname)
        os.rename(tmx_path, new_tmx_path)
        return new_tmx_path
    else:
        logging.error(f"Package {from_xlat_omt_path} not found")
        return None


def list_has_one_omt(dirpath, from_xlat_dir):
    """ Checks that the files inside dir contain only one OMT file """
    return len([f for f in os.listdir(os.path.join(dirpath, from_xlat_dir)) if str(f).endswith('.omt')]) == 1


def do_create_rec_omtpkg(wrkflw_dir_path, rec_files):
    """ Creates the reconciliation project packages including the TMs from the two translation packages. """

    for dirpath, children_dirs, children_files in os.walk(wrkflw_dir_path):

        from_xlat_dirs = next(iter(rec_files.values()))
        omtpkg_torec_dir = list(rec_files.keys())[0]

        # we are in the version folder
        if from_xlat_dirs[0] in children_dirs \
                and from_xlat_dirs[1] in children_dirs \
                and omtpkg_torec_dir in children_dirs:  # all 3 dirs (t1, t2, rec) are here, we're in the right place

            # t1 and t2 pkgs exist and rec pkg has not been created
            if list_has_one_omt(dirpath, from_xlat_dirs[0]) \
                    and list_has_one_omt(dirpath, from_xlat_dirs[1]) \
                    and not list_has_one_omt(dirpath, omtpkg_torec_dir):

                logging.info("Let's create the project package for reconciliation")

                t1_tmx_relpath = extract_internal_tm(dirpath, from_xlat_dirs[0])
                t2_tmx_relpath = extract_internal_tm(dirpath, from_xlat_dirs[1])

                if t1_tmx_relpath and t2_tmx_relpath:
                    print("Internal TMs extracted")
                    # copy t1_omtpkg to rec dir
                    t1_omtpkg_path = get_path_of_1st_omt_in_dir(dirpath, from_xlat_dirs[0])
                    version_dname = os.path.basename(dirpath)  # lll-CCC (version and folder name)
                    omtpkg_instance_name = instantiate_fname_from_template(params['omtpkg_name_template'],
                                                                           version=version_dname)
                    omtpkg_instance_path = os.path.join(dirpath, omtpkg_torec_dir, omtpkg_instance_name)
                    # only accepts strings, for paths use os.path.copy
                    copyfile(t1_omtpkg_path, omtpkg_instance_path)  # two strings
                    # remove internal tm
                    filenames = 'omegat/project_save.tmx*', 'omegat/last_entry.properties',  # tuple
                    remove_from_zip(omtpkg_instance_path, *filenames)
                    # add T1 and T2 tmx's
                    add_files_to_zip(omtpkg_instance_path, [t1_tmx_relpath, t2_tmx_relpath], 'tm')
        else:
            # Either the T1 and/or T2 packages are not there, or the Rec package already exists.
            pass


def normalize_path(path):
    ''' Turns Windows path mounted at company into an absolute unix path.
    >>> normalize_path("u:\IPSOS\TEST_DAN")
    /media/data/data/company/IPSOS/TEST_DAN
    '''
    if re.match("^/media/data/data/company/", path):
        # it is already a unix path
        return path
    elif re.match("\w:\\\\", path[0:3]) and not re.match("/", path):
        ## path is windows path
        logging.debug(f"{path=} is a windows path")
        path_unix = path.replace(ntpath.sep, posixpath.sep)
        logging.debug(f"{path_unix=}")
        normalized_path = re.sub(r"\w:", "/media/data/data/company", path_unix)
        logging.debug(f"{normalized_path=}")
        return normalized_path

# ############# CONSTANTS ###########################################

# config_df = get_df_from_xlsx(config_path, sheet_name = None)
params = get_colpair_from_ws(config_path, sheet_name='params', use_cols=['key', 'value'])  # dict
options = get_colpair_from_ws(config_path, sheet_name='options', use_cols=['key', 'value'])  # dict
tasks = [sheet for sheet in pd.ExcelFile(config_path).sheet_names if re.match(r"\d\d_[A-Z]{3}", sheet)] # e.g. 01_TRA, 02_ADA, etc.
logging.debug(f"{tasks=}")

# params
root = params['root'].rstrip('/')
logging.debug(f'{root=}')
root = normalize_path(root)
logging.debug(f'{root=}')

project = params['project'].strip()
workflow_parent_dir = instantiate_fname_from_template(params['workflow_parent_dir']) # abs path
# do_not_archive_bundle = ','.params['project'].strip()

# options
try:
    delete_empty_version_folders = get_boolean_value(options['delete_empty_version_folders'])
    create_omtpkg_instances = get_boolean_value(options['create_omtpkg_instances'])
    deploy_init_bundle = get_boolean_value(options['deploy_init_bundle'])
    overwrite_folders = get_boolean_value(options['overwrite_folders'])
    overwrite_packages = get_boolean_value(options['overwrite_packages'])
    double_xlat = get_boolean_value(options['double_xlat'])
    double_xlat_merge = get_boolean_value(options['double_xlat_merge'])
    adaptation = get_boolean_value(options['adaptation'])
except Exception as e:
    logging.error(f"Unable to get some option(s): \n {e}.")

# lists of paths
try:
    toXl8rs_dirs = [params['omtpkg_toXlat1_dir'].rstrip('/')]

    if double_xlat:
        toXl8rs_dirs.append(params['omtpkg_toXlat2_dir'].rstrip('/'))

    if double_xlat_merge:
        reconciliation_files = {
            params['omtpkg_toRec_dir'].rstrip('/'): [
                params['omtpkg_fromXlat1_dir'].rstrip('/'),
                params['omtpkg_fromXlat2_dir'].rstrip('/')
            ]
        }

    if adaptation and params.has_key('omtpkg_toAdap_dir'):
            toAdaps_dirs = [params['omtpkg_toAdap_dir'].rstrip('/')]
    else:
        toAdaps_dirs = []

except Exception as e:
    logging.error(f"Unable to get parameter: \n {e}.")

tasks_dirs = [toXl8rs_dirs, toAdaps_dirs]
logging.debug(f"{tasks_dirs=}")
#tasks_dirs = {'TRA': toXl8rs_dirs, 'ADA': toAdaps_dirs}

init_bundle_fname = os.path.basename(init_path)
workflow_name = strip_file_extension(init_bundle_fname)  # = wave

# print(f'workflow_name (wave): {workflow_name}')
workflow_dir_path = os.path.join(workflow_parent_dir, workflow_name)  # abs path

# /cli_automation/conv_multilingual_wb_to_tmxs/langtags_20181210.csv
# mq2caps_langtag_mapping = build_2langtag_mapping_from_csv(mapping_path, use_cols = ['BCP47', 'cApStAn'])  # dict
mq2caps_langtag_mapping = build_2langtag_mapping(mapping_path, use_cols=['memoq3', 'cApStAn'], sheet_name='mq2caps')
caps2ot4_langtag_mapping = build_2langtag_mapping(mapping_path, use_cols=['cApStAn', 'OmegaT4'], sheet_name='mq2caps')


mq_langtags = [tag for tag in mq2caps_langtag_mapping.keys() if isinstance(tag, str)]  # list # todo: skip nan
# 'fas / prs',

# ############# BUSINESS LOGIC ###########################################

if __name__ == '__main__':

    # trigger/input is the init bundle
    if deploy_init_bundle and Path(init_path).exists() and not Path(workflow_dir_path).exists():
        logging.debug(f'Deploying...')
        logging.info(f'workflows parent dir: {workflow_parent_dir}')  ##
        logging.info(f"I will deploy init bundle {init_bundle_fname} as {workflow_dir_path}")
        unpack_bundle(init_path, workflow_dir_path)  # deploy_init
        # todo: archive init_bundle if not found in do_not_archive_bundle list
        # todo: check that workflow_dir_path exists and list its contents
        do_deploy_workflow(workflow_dir_path)
        #x_do_deploy_workflow(workflow_dir_path)
        logging.info("-----------------------")
    # update version folders (using templates already archived in _tech)
    elif Path(workflow_dir_path).exists():
        logging.warning(f"Workflow '{os.path.basename(workflow_dir_path)}' already deployed...")
        logging.debug(f'Update version folders')
        do_deploy_workflow(workflow_dir_path)
        logging.info("-----------------------")


    # trigger/input is the source files + omt template
    if create_omtpkg_instances:
        logging.info(f'workflow_dir_path: {workflow_dir_path}')
        omtpkg_template_path = get_omtpkg_template_path(workflow_dir_path)
        version_files = get_files_per_version(workflow_dir_path)
        for task_dirs in tasks_dirs:
            do_create_omtpkg_instances(workflow_dir_path, version_files, omtpkg_template_path, task_dirs)
        logging.info("-----------------------")

    # trigger/input is the 2 xlat pkgs
    if double_xlat_merge:
        logging.info(f"Let's see whether any T1 and T2 packages are ready for merging...")
        omtpkg_template_path = get_omtpkg_template_path(workflow_dir_path)
        do_create_rec_omtpkg(workflow_dir_path, reconciliation_files)
        logging.info("-----------------------")

    update_docs()


# todo: move init_path to the parent_dir of init_path