from __future__ import print_function
import os
import platform


REPO_ROOT = os.path.dirname(os.path.abspath(__file__))

def run(distro, pkg):
    docker_dir = os.path.join(REPO_ROOT,
                              "docker",
                              distro)

    print("Building '{}'".format(docker_dir))
    ret = os.system("docker build -t dvc {}".format(docker_dir))
    assert ret == 0

    cmd = "docker run " \
           "-v ~/.aws:/root/.aws " \
           "-v {}:/dvc " \
           "-w /dvc/{} " \
           "--rm " \
           "-t dvc " \
           "./upload.sh".format(REPO_ROOT, pkg)

    print("Running 'dvc' image: {}".format(cmd))
    ret = os.system(cmd)
    assert ret == 0


run('ubuntu', 'deb')
run('fedora', 'rpm')
