import requests
import os
import pathlib
import json

parent_dir_abspath = pathlib.Path(__file__).parent.absolute()

file = os.path.join(parent_dir_abspath, "test3.md")

if os.path.exists(file):
    with open(file, 'rb') as f:
        r = requests.post('https://capps.capstan.be/doc/upload_md.php', data = {"submit": "submit"}, files={'testx.md': f})

    r = json.loads(r.text)
    print(r['status'])