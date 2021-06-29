import argparse
from pathlib import Path
from subprocess import STDOUT, check_call

dpath = Path(__file__).parent

parser = argparse.ArgumentParser()
parser.add_argument(
    "pkg", choices=["deb", "rpm"], help="package type",
)
args = parser.parse_args()

image = {"deb": "ubuntu", "rpm": "fedora"}[args.pkg]

check_call(f"docker build -t dvc docker/{image}", stderr=STDOUT, shell=True)

flags = " ".join(
    [
        "-e GPG_ITERATIVE_ASC",
        "-e GPG_ITERATIVE_PASS",
        "-v ~/.aws:/root/.aws",
        f"-v {dpath.resolve()}:/dvc",
        f"-w /dvc/{args.pkg}",
        "--rm",
    ]
)

check_call(
    "docker run {flags} -t dvc ./upload.sh", stderr=STDOUT, shell=True,
)
