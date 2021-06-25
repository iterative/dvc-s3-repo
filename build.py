import argparse
import os
import shutil
from subprocess import check_call, STDOUT
from pathlib import Path

dpath = Path(__file__).parent

parser = argparse.ArgumentParser()
parser.add_argument(
    "pkg", choices=["deb", "rpm"], help="package type"
)
args = parser.parse_args()

check_call(f"docker build -t dvc-s3-repo docker/centos", stderr=STDOUT, shell=True)

cmd = " && ".join(
    [
        "pip install -U pip",
        "pip install wheel",
        "pip install ./dvc[all]",
        "pip install -r dvc/scripts/build-requirements.txt",
        f"python dvc/scripts/build.py {args.pkg}",
    ]
)

check_call(
    f"docker run -v {dpath.resolve()}:/dvc-s3-repo -w /dvc-s3-repo --rm -t dvc-s3-repo bash -c '{cmd}'",
    stderr=STDOUT, shell=True,
)

for path in (dpath / "dvc" / "scripts" / "fpm").glob(f"*.{args.pkg}"):
    shutil.copy(path, dpath)
