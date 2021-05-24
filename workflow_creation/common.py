import logging
import os, re, sys
import os.path
import shutil
import pandas as pd
from zipfile import ZipFile
from fnmatch import fnmatch
import tempfile


def myfunc(x):
	print(f"hello world, dear {x}")


def delete_folder(folder_path):
	""" Deletes folder with the right approach depending on its state """
	logging.info("Logging from inside the delete_folder function")
	# checking whether folder exists or not
	if os.path.exists(folder_path):
		# checking whether the folder is empty or not
		if len(os.listdir(folder_path)) == 0:
			# removing the file using the os.remove() method
			logging.info(f"Removing '{folder_path}'")
			os.rmdir(folder_path)
		else:
			# messaging saying folder not empty
			logging.warning("Folder is not empty")
			try:
				shutil.rmtree(folder_path)
			except OSError as e:
				logging.error("Error: %s - %s." % (e.filename, e.strerror))

			# confirm the folder is not there anymore, otherwise raise error
	else:
		# file not found message
		logging.warning("File not found in the directory")


def rel(root, path):
	""" Removes the part of the path from / to the project folder. """
	path_str = str(path)
	return path_str.replace(root, '')


def get_config(df):
	#sheet = wb.sheet_by_index(sheet_idx)
	parameters = df.iloc[:, 0] # first column
	values = df.iloc[:, 1] # second column
	return dict(zip(parameters, values))


def get_version_from_path(path):
	""" Gets capstan code (version) from path (from subfolder under task folder) """
	try:
		regex = re.compile(r'(?<=0\d_(TRA|ADA)/)[a-z]{3}-[A-Z]{3}(?=/)')
		m = re.search(regex, path)
		return m.group(0)
	except AttributeError:
		logging.error("No version found in the path, cannot continue.") # log warning
		sys.exit()


def build_langtag(parent_dir, version): # move to module
	path_to_langtags_file = os.path.join(parent_dir, 'config', 'langtags_20210303.xlsx')
	langtag_pd = pd.read_excel(path_to_langtags_file, index_col=None)
	langtag_lookup = dict(zip(langtag_pd['cApStAn'], langtag_pd['OmegaT']))
	version_dict = {'capstan': version, 'omegat': langtag_lookup[version]}
	return version_dict
# def move original templates and rename them if details change in config


def get_omtproj_lang(path_to_file, proj_lang_elem):
	if not os.path.isfile(path_to_file):
		logging.error(f"File {path_to_file} not found")
		return False

	with open(path_to_file) as f:
		xml = f.read()
		regex = re.compile(f"(?<=<{proj_lang_elem}>).+(?=</{proj_lang_elem}>)")
		m = re.search(regex, xml)
	return m.group(0)


def remove_from_zip(zipfname, *filenames):
	logging.info(f"filenames: {filenames} ")
	#tempdir = tempfile.mkdtemp()
	try:
		# tempname = os.path.join(tempdir, 'new.zip')
		tempname = "temp.zip"
		with ZipFile(zipfname, 'r') as zipread:
			logging.warning(f"Reading the old zip")
			with ZipFile(tempname, 'w') as zipwrite:
				logging.warning(f"Writing the new zip")
				for item in zipread.infolist():
					if item.filename not in filenames and not any(fnmatch(item.filename, f) for f in filenames):
						logging.info(f"Will keep {item.filename}")
						data = zipread.read(item.filename)
						zipwrite.writestr(item, data)
					else:
						logging.info(f"Removing {item.filename}")

		shutil.move(tempname, zipfname)
	except Exception as e:
		logging.error(f"There was an error removing files from the zip {zipfname}: {e}")


def add_files_to_zip(zip_path, fpaths, location):
	""" Adds file to zip in location inside zip, returns True if successful """
	try:
		logging.info(f"Files in {fpaths} will be added to {os.path.basename(zip_path)}.")
		with ZipFile(zip_path, "a") as z:
			for fpath in fpaths:
				fname = os.path.basename(fpath)
				z.write(fpath, f'{location}/{fname}')

		return True
	except Exception as e:
		logging.error(f"Unable to add files to zip {zip_path}:\n {e}.")
		return False


def x_build_path(parent_dir_path_str, filename):  # not used
	""" Creates real path from the pieces to the file """
	file_path_str = os.path.join(parent_dir_path_str, filename)  # arg
	return Path(file_path_str).absolute()


def x_get_df_from_sheet_in_ods(config_file_path, sheet_name):  # not used
	""" Reads spreadsheet and outputs df """
	if config_file_path.exists():
		df = read_ods(config_file_path, sheet_name)
		return df
	else:
		logging.warning("The .ods file does not exist)")
		return None


def x_get_df_from_xlsx(config_file_path, sheet_name):  # not used
	""" Reads spreadsheet and outputs df """
	if config_file_path.exists():
		df = pd.read_excel(config_file_path, sheet_name=sheet_name)
		return df
	else:
		logging.warning("The .xlsx file does not exist)")
		return None


def x_fstring(tmpl_str):  # not used in this script (use instantiate_fname_from_template, which is clearer)
	""" Converts template names that come from the config file into actual strings,
	replacing placeholders between curly brackets with values of previously instantiated values."""
	return eval(f"f'{tmpl_str}'")


def x_do_deploy_init_bundle(init_path):  # not used
	""" Fetches the initiation bundle and unpacks it in the 08_WORKFLOWS folder. """
	if init_path.exists():
		pass
	else:
		logging.error("The file does not exist)")
		return None


def x_get_version_dir_path(capstan_langcode):   # not used
    if folders_created and any(str(path).endswith(capstan_langcode) for path in folders_created):
        version_dir_path = [path for path in folders_created if(str(path).endswith(capstan_langcode))][0]
        logging.info(f"Version folders created successfully, including folder for {capstan_langcode}")
        return version_dir_path
    else:
        logging.warning(f"Version folders not created successfully or folder for {capstan_langcode} not included")
        return None
