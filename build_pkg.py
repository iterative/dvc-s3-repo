import argparse
import os
import pathlib
import shutil
from subprocess import STDOUT, check_call, check_output

path = pathlib.Path(__file__).parent.absolute()
dvc = path.parent.parent / "dvc"

dist = path / "dist"
build = path / "build"
install = build / "usr"

parser = argparse.ArgumentParser()
parser.add_argument("pkg", choices=["deb", "rpm"], help="package type")
args = parser.parse_args()

flags = [
    "--description",
    '"Data Version Control | Git for Data & Models"',
    "-n",
    "dvc",
    "-s",
    "dir",
    "-f",
    "--license",
    '"Apache License 2.0"',
]

if args.pkg == "rpm":
    # https://github.com/jordansissel/fpm/issues/1503
    flags.extend(["--rpm-rpmbuild-define", "_build_id_links none"])

bash_dir = build / "etc" / "bash_completion.d"
dirs = ["usr", "etc"]
flags.extend(["--depends", "git >= 1.7.0"])  # needed for gitpython

try:
    shutil.rmtree(build)
except FileNotFoundError:
    pass

lib = install / "lib"
lib.mkdir(parents=True)
shutil.copytree(dist / "dvc", lib / "dvc")

(install / "bin").mkdir()
os.symlink("../lib/dvc/dvc", install / "bin" / "dvc")

bash_dir.mkdir(parents=True)
bash_completion = check_output(
    [lib / "dvc" / "dvc", "completion", "-s", "bash"], text=True
)
(bash_dir / "dvc").write_text(bash_completion)

zsh_dir = install / "share" / "zsh" / "site-functions"
zsh_dir.mkdir(parents=True)
zsh_completion = check_output(
    [lib / "dvc" / "dvc", "completion", "-s", "zsh"], text=True
)
(zsh_dir / "_dvc").write_text(zsh_completion)

version = check_output([lib / "dvc" / "dvc", "--version"], text=True).strip()

check_call(
    [
        "fpm",
        "--verbose",
        "-t",
        args.pkg,
        *flags,
        "-v",
        version,
        "-C",
        build,
        *dirs,
    ],
    cwd=path,
    stderr=STDOUT,
)
