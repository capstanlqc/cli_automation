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

# ############# AUTHORSHIP INFO ###########################################

__author__ = "Manuel Souto Pico"
__copyright__ = "Copyright 2021, cApps/cApStAn"
__credits__ = ["Manuel Souto Pico"]
__license__ = "GPL"
__version__ = "0.2.0"
__maintainer__ = "Manuel Souto Pico"
__email__ = "manuel.souto@capstan.be"
__status__ = "Testing / pre-production" # "Production"

# ############# IMPORTS ###########################################

import os
import re, sys
import argparse
import xlrd
from yattag import Doc, indent
import pandas
# from pprint import pprint
# import xml.dom.minidom

# ############# PROGRAM DESCRIPTION ###########################################

text = "This is TM Workbook Converter: it takes a spreadsheet/workbook where each \
column contains a language version and produces as many TMX files as target \
languages the workbook has."

# intialize arg parser with a description
parser = argparse.ArgumentParser(description=text)
parser.add_argument("-V", "--version", help="show program version",
                    action="store_true")
parser.add_argument("-i", "--input", help="specify path to input file")

# read arguments from the command line
args = parser.parse_args()

# check for -V or --version
if args.version:
    print("This is program TM Workbook Converter version 0.2")
    sys.exit()

if args.input:
    print("Processing %s" % args.input)

# check for -V or --version
if args.version:
    print("This is Flash Prepp/Extract utility version 0.1.0")
    sys.exit()

if args.input:
    path_to_wb = args.input.rstrip('/')
else:
    print("Argument -i not found.")
    sys.exit()

# ############# FUNCTIONS #####################################################

def map_langtag_loc(df, tag, xfrom, xto):
    # print(langtags.loc[langtags.cApStAn == x, 'OmegaT'].values[0])
    return df.loc[df[xfrom] == tag, xto].values[0]


def map_langtag(df, tag, xfrom, xto):
    # langtags_dict = dict(zip(langtags['cApStAn'], langtags['OmegaT']))
    langtags_dict = dict(zip(df[xfrom], df[xto]))
    return langtags_dict[tag]


def get_config(wb, sheet_idx):
    sheet = wb.sheet_by_index(sheet_idx)
    parameters = sheet.col_values(0)
    values = sheet.col_values(1)
    return dict(zip(parameters, values))


def get_data(wb, sheet_idx, source_col, target_col):
    # if sheet0 has name "config", if not use sheet0
    sheet = wb.sheet_by_index(sheet_idx)
    # print(sheet.cell_value(2,1))
    # print(sheet.nrows)
    # print(sheet.ncols)
    # print(sheet.row_values(0))
    source_texts = sheet.col_values(source_col)
    target_texts = sheet.col_values(target_col)
    return set(zip(source_texts, target_texts))


def get_headers(wb, sheet_idx, row_idx):
    sheet = wb.sheet_by_index(sheet_idx)
    return sheet.row_values(row_idx)


def build_tmx(langpair_set, xml_source_lang, xml_target_lang):
    # convert to tmx
    doc, tag, text = Doc().tagtext()

    doc.asis('<?xml version="1.0" encoding="UTF-8"?>')
    with tag('tmx', version="1.4"):
        with tag('header', creationtool="cApps", creationtoolversion="2020.10",
                 segtype="paragraph", adminlang="en",
                 datatype="HTML", srclang=xml_source_lang):
            doc.attr(
                ('o-tmf', "omt") # o_tmf="omt",
            )
            text('')
        with tag('body'):
            for tu in langpair_set:
                src_txt = str(tu[0]).strip()
                tgt_txt = str(tu[1]).strip()
                with tag('tu'):
                    with tag('tuv'):
                        doc.attr(
                            ('xml:lang', xml_source_lang)
                        )
                        with tag('seg'):
                            text(src_txt)
                    with tag('tuv'):
                        doc.attr(
                            ('xml:lang', xml_target_lang)
                        )
                        with tag('seg'):
                            text(tgt_txt)

    tmx_output = indent(
        doc.getvalue(),
        indentation=' '*2,
        newline='\r\n'
    )
    return tmx_output  # .replace("o_tmf=", "o-tmf=")


def get_langs(wb, config):
    return [x for x in get_headers(wb, 1, int(config['header_row']))
            if re.match(r'[a-z]{3}-[A-Z]{3}', x) and x != config['source_lang']]


def write_tmx_file(config, tmx_output):
    # build filename
    config['tmx_file_names'] = config['tmx_file_names'].replace('<', '').replace('>', '')
    fn_parts = [config[x.strip()] if x.strip() in config.keys()
                else x.strip()
                for x in config['tmx_file_names'].split(',')]

    #check if output folder exists, create it if it does not

    output_folder_name = "output"

    if os.path.exists(output_folder_name):

      print(f"Folder {output_folder_name} already exist, not creating.")
    else:
      # Creates the folder
      os.mkdir(output_folder_name)
      print(f"{output_folder_name} folder created.")
  
    # writing output
    filename = "_".join(fn_parts) + ".tmx"
    print("Writing TMX output to file " + filename)
    with open("output/" + filename, "w") as f:
        print(tmx_output, file=f)


# all source language variables should be global!: path_to_file, wb, langtags
def convert_wb_to_tmx_files(path_to_file, langtags_csv):

    wb = xlrd.open_workbook(path_to_file)
    config = get_config(wb, 0)
    lang_list = get_langs(wb, config)
    columns = get_headers(wb, 1, int(config['header_row']))
    langtags = pandas.read_csv(langtags_csv)
    xml_src_tag = map_langtag(langtags, config['source_lang'], 'cApStAn',
                              'OmegaT').split('-')[0]
    # xml_src_tag = xml_src_tag.split('-')[0]  # use only subtgg for compliance
    source_col = columns.index(config['source_lang'])

    # convert_colpair_to_tmx_file() for idx, col in cols if col in lang_list
    for idx, col in enumerate(columns):
        if col in lang_list:
            lang_config = dict(config, target_lang=col)  # update dict without modify original dictionary
            xml_tgt_tag = map_langtag(langtags, col, 'cApStAn', 'OmegaT')
            langpair_set = get_data(wb, sheet_idx=1, source_col=source_col, target_col=idx)
            tmx_output = build_tmx(langpair_set, xml_src_tag, xml_tgt_tag)
            write_tmx_file(lang_config, tmx_output)


# ############# EXECUTION #####################################################


convert_wb_to_tmx_files(path_to_wb, 'langtags_20181210.csv')

# ############# WIP ###########################################################

# done:
# 1. parse excel, extract each language pair (cols 1.3)
# 2. put each language pair in one tmx

# todo:
# 1. segment paragraphs whenever possible
# 2. clean up tags
