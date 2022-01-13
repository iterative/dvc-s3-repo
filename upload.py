import argparse
from pathlib import Path

from utils import DockerBuilder

dpath = Path(__file__).parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "pkg",
        choices=["deb", "rpm"],
        help="package type",
    )
    args = parser.parse_args()
    tag = f"dvc-{args.pkg}"
    image = {"deb": "ubuntu", "rpm": "fedora"}[args.pkg]
    docker_dir = f"docker/{image}"
    target = "upload" if image == "ubuntu" else None

    image = DockerBuilder(
        pkg=args.pkg, tag=tag, directory=docker_dir, target=target
    )
    image.build()
    image.run_upload_package()


if __name__ == "__main__":
    main()
