import os
import shutil
import sys
from pathlib import Path
from typing import List, Optional, Tuple

import docker

dpath = Path(__file__).parent

Images = Tuple[docker.models.images.Image]


class DockerBuilder:
    working_dir = Path("/dvc-s3-repo")
    volumes = {str(dpath.resolve()): {"bind": str(working_dir), "mode": "rw"}}

    def __init__(
        self,
        pkg: str,
        tag: str,
        directory: str,
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
                    "pip install -U pip",
                    "pip install wheel",
                    "pip install './dvc[all]'",
                    "pip install -r dvc/scripts/build-requirements.txt",
                    f"python dvc/scripts/build.py {self.pkg}",
                ]
            ),
        ]

    def build(self, **kwargs) -> Images:
        print(f"* Building {self.tag} from {self.dir}")
        try:
            images: Images = self.client.images.build(
                path=self.dir, tag=self.tag, target=self.target, **kwargs
            )
        except docker.errors.BuildError as exc:
            print("* Build failed: ")
            for line in exc.build_log:
                try:
                    print(line["stream"], end="")
                except KeyError:
                    print(line, file=sys.stderr)
            raise
        return images

    def run(self, command: str, **kwargs):
        print(f"* Starting container {self.tag} with cmd: {command}")
        try:
            return self.client.containers.run(
                self.tag, command=command, stdout=True, stderr=True, **kwargs
            )
        except docker.errors.ContainerError as exc:
            print("* failed:\n", exc.stderr.decode("UTF-8"), end="")
            raise

    def run_build_package(self):
        self.run(
            command=self.get_pkg_build_cmd(),
            volumes=self.volumes,
            working_dir=str(self.working_dir),
            auto_remove=True,
        )
        for path in (dpath / "dvc" / "scripts" / "fpm").glob(f"*.{self.pkg}"):
            shutil.copy(path, dpath)
            print(f"Copied {path} to {dpath}")

    def run_upload_package(self):
        env_passthrough = ["GPG_ITERATIVE_ASC", "GPG_ITERATIVE_PASS"]
        all_vols = {
            **self.volumes,
            str(Path("~/.aws").expanduser()): {
                "bind": "/root/.aws",
                "mode": "rw",
            },
        }
        out = self.run(
            command="./upload.sh",
            environment={key: os.environ.get(key) for key in env_passthrough},
            volumes=all_vols,
            working_dir=str(self.working_dir / self.pkg),
            auto_remove=True,
        )
        print(out.decode("UTF-8"))
