import argparse

from utils import DockerBuilder

docker_map = {
    "deb": {
        "dir": "docker/ubuntu",
        "tag": "dvc-s3-repo-deb:latest",
        "target": "base",
    },
    "rpm": {
        "dir": "docker/centos",
        "tag": "dvc-s3-repo-rpm:latest",
        "target": "base",
    },
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pkg", choices=["deb", "rpm"], help="package type")

    args = parser.parse_args()

    info = docker_map[args.pkg]
    docker_dir: str = info.get("dir")
    tag: str = info.get("tag")
    target: str = info.get("target")

    image = DockerBuilder(
        pkg=args.pkg,
        tag=tag,
        directory=docker_dir,
        target=target,
    )
    image.build()
    image.run_build_package()


if __name__ == "__main__":
    main()
