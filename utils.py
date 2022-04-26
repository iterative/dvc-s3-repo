import os
import shutil
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

import docker

dpath = Path(__file__).parent


class DockerBuilder:
    working_dir = Path("/dvc-s3-repo")
    volumes = {str(dpath.resolve()): {"bind": str(working_dir), "mode": "rw"}}

    def __init__(
        self,
        pkg: str,
        tag: str,
        directory: Optional[str] = None,
        target: Optional[str] = None,
    ):
        self.client = docker.from_env()
        self.dir = directory
        self.pkg = pkg
        self.tag = tag
        self.target = target

    def get_pkg_build_cmd(self) -> List[str]:
        return [
            "bash",
            "-c",
            " && ".join(
                [
                    "pip install './dvc[all]'",
                    "pip install -r dvc/scripts/build-requirements.txt",
                    f"python dvc/scripts/build.py {self.pkg}",
                ]
            ),
        ]

    @staticmethod
    def _pretty_print(log: List[Dict[str, Any]]) -> None:
        for line in log:
            if "stream" in line:
                print(line["stream"], end="")
            elif "error" in line:
                print(line["error"], file=sys.stderr)
            else:
                print(line, file=sys.stderr)

    def build(self, **kwargs) -> docker.models.images.Image:
        print(f'* Building "{self.tag}" from "{self.dir}"')
        try:
            image, log = self.client.images.build(
                path=self.dir, tag=self.tag, target=self.target, **kwargs
            )

        except docker.errors.BuildError as exc:
            print("* Build failed: ")
            log = list(exc.build_log)
            raise
        finally:
            self._pretty_print(log)
        return image

    def run(self, command: str, **kwargs) -> int:
        """Runs the given command and returns the status code"""
        print(f"* Starting container {self.tag} with cmd: {command}")
        container = self.client.containers.run(
            self.tag,
            command=command,
            stdout=True,
            stderr=True,
            detach=True,
            **kwargs,
        )

        for line in container.logs(stream=True):
            print(line.strip().decode("UTF-8"))

        status = container.wait()
        if status["Error"]:
            print(f"* Failed! Error: {status['Error']}")
        return status["StatusCode"]

    def run_build_package(self) -> None:
        status = self.run(
            command=self.get_pkg_build_cmd(),
            volumes=self.volumes,
            working_dir=str(self.working_dir),
            auto_remove=True,
        )
        if status:
            print(f"* Failed to build {self.pkg} package", file=sys.stderr)
            sys.exit(status)

        for path in (dpath / "dvc" / "scripts" / "fpm").glob(f"*.{self.pkg}"):
            shutil.copy(path, dpath)
            print(f"Copied {path} to {dpath}")

    def run_upload_package(self) -> None:
        env_passthrough = ["GPG_ITERATIVE_ASC", "GPG_ITERATIVE_PASS"]
        all_vols = {
            **self.volumes,
            str(Path("~/.aws").expanduser()): {
                "bind": "/root/.aws",
                "mode": "rw",
            },
        }
        status = self.run(
            command="./upload.sh",
            environment={key: os.environ.get(key) for key in env_passthrough},
            volumes=all_vols,
            working_dir=str(self.working_dir / self.pkg),
            auto_remove=True,
        )
        if status:
            print(f"* Failed to build {self.pkg} package", file=sys.stderr)
            sys.exit(status)

    def run_test_package(self) -> None:
        status = self.run(
            command=f"./test.sh {self.pkg}",
            volumes=self.volumes,
            working_dir=str(self.working_dir),
            auto_remove=True,
        )
        if status:
            print(f"* Test for {self.pkg} package failed", file=sys.stderr)
            sys.exit(status)
