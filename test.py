import argparse

from utils import DockerBuilder


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pkg", choices=["deb", "rpm"], help="package type")

    args = parser.parse_args()

    docker_dir = f"docker/{args.pkg}"
    tag: str = f"dvc-s3-repo-{args.pkg}"
    target = "pyenv"

    image = DockerBuilder(
        pkg=args.pkg,
        tag=tag,
        directory=docker_dir,
        target=target,
    )
    image.run_test_package()


if __name__ == "__main__":
    main()
