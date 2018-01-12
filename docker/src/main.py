import os
import subprocess

import click
import docker


client = docker.from_env()


@click.group()
def cli():
    pass

@cli.command()
@click.option('--registry', required=True, help='The docker registry to pull from')
@click.option('--repository', required=True, help='The docker repostiroy')
@click.option('--tag', default='latest', help='The image tag to pull')
def pull(registry, repository, tag):
    name = '{}/{}'.format(registry, repository)
    client.images.pull(name, tag=tag)


@cli.command()
@click.option('--dockerfile', required=True, help='The Dockerfile path.')
@click.option('--name', required=True, help='The image name.')
@click.option('--tag', required=True, help='The image tag.')
@click.option('--out', help='The file to write ID to.')
@click.option('--ctx', help='The build context directory.')
def build(dockerfile, name, tag, out=None, ctx=None):
    tag = "%s:%s" % (name, tag)
    print(open(dockerfile).read())
    if not ctx:
        ctx, _ = os.path.split(dockerfile)
    # FIXME: We have to use docker command line b/c calling python lib seems to fail with some weird NOT FOUND error.
    #img = client.images.build(path=dirpath, tag=tag, dockerfile=dockerfile)
    #imgid = img.id

    cmd = "docker build -q -t={} -f={} .".format(tag, dockerfile)
    imgid = subprocess.check_output(cmd, shell=True)

    if out:
        with open(out, 'w') as f:
            f.write(imgid)


if __name__ == '__main__':
    cli()
