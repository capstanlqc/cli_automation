import logging
import os, re, sys
import os.path
import shutil
import pandas as pd
import zipfile
import tempfile

def myfunc(x):
	print(f"hello world, dear {x}")


def delete_folder(folder_path):
	''' Deletes folder with the right approach depending on its state '''
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
	''' Removes the part of the path from / to the project folder '''
	path_str = str(path)
	return path_str.replace(root, '')


def get_config(df):
	#sheet = wb.sheet_by_index(sheet_idx)
	parameters = df.iloc[:, 0] # first column
	values = df.iloc[:, 1] # second column
	return dict(zip(parameters, values))


def get_version_from_path(path):
	''' Gets capstan code (version) from path (from subfolder under task folder) '''
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
		with zipfile.ZipFile(zipfname, 'r') as zipread:
			logging.warning(f"Reading the old zip")
			with zipfile.ZipFile(tempname, 'w') as zipwrite:
				logging.warning(f"Writing the new zip")
				for item in zipread.infolist():
					if item.filename not in filenames:
						logging.info(f"Will keep {item.filename}")
						data = zipread.read(item.filename)
						zipwrite.writestr(item, data)
					else:
						logging.info(f"Removing {item.filename}")

		shutil.move(tempname, zipfname)
	except:
		logging.error(f"There was an error removing files from the zip {zipfname}")
