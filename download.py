import pathlib
import shutil

import git

VERSION = "2.20.0"
URL = "https://github.com/iterative/dvc"

path = pathlib.Path(__file__).parent.absolute()
dvc = path / "dvc"

try:
    shutil.rmtree(dvc)
except FileNotFoundError:
    pass

# NOTE: need full git clone for version detection
# by setuptools-scm
repo = git.Repo.clone_from(URL, dvc)
repo.git.checkout(VERSION)

# FIXME temporary fix for 2.20.0
(dvc / "scripts" / "pyinstaller" / "hooks" / "hook-fsspec.py").write_text(
    'hiddenimports = ["fsspec.implementations.memory"]'
)
