def _format_list(ls):
  return str(ls)


def _format_ports(ps):
  return " ".join(ps)


def _format_env(env):
  result = ""
  for k, v in env.items():
    result = "%s %s=%s" % (result, k, v)
  return result


def _format_files(files):
  xs = []
  for k, v in files.items():
    xs.append("%s %s" % (k, v))
  return r" \ \n".join(xs)


# TODO: How to protect against someone remove image from docker!?
def _build_impl(ctx, name=None, base=None, cmd=None, entrypoint=None, env=None, files=None, ports=None, stamp=None, tag=None):
  # TODO: https://docs.bazel.build/versions/master/skylark/rules.html#runfiles

  # TODO: Only build if hash is different then returned from `docker inspect --format="{{.Id}}" registry.newstore.io/services/hqs:image`.

  ctx.actions.expand_template(
    template=ctx.file._dockerfile_tmpl,
    output=ctx.outputs.dockerfile,
    # TODO: Add files, labels.
    substitutions={
      "{BASE}": base or ctx.attr.base,
      "{ENTRYPOINT}": _format_list(entrypoint or ctx.attr.entrypoint),
      "{CMD}": _format_list(cmd or ctx.attr.cmd),
      "{FILES}": _format_files(files),
      "{PORTS}": _format_ports(ports or ctx.attr.ports),
      "{ENV}": _format_env(env or ctx.attr.env),
    }
  )

  ctx.actions.run(
    mnemonic = "BuildImage",
    outputs = [ctx.outputs.out],
    inputs = [ctx.outputs.dockerfile],
    executable=ctx.executable._script,
    arguments=[
      "build",
      "--name", name or ctx.attr.name,
      "--dockerfile", ctx.outputs.dockerfile.path,
      "--tag", tag or ctx.attr.tag,
      "--out", ctx.outputs.out.path,
      "--ctx", ctx.label.package,
    ],
    progress_message="Building docker image ...",
    env={
        'PATH': '/bin:/usr/bin:/usr/local/bin',
    },
  )

_base_build_attrs = {
  "_script": attr.label(
    executable = True,
    default = Label("//tools:docker.par"),
    allow_files=True,
    single_file=True,
    cfg = "host",
  ),
  '_dockerfile_tmpl': attr.label(
    default = Label("//templates:Dockerfile.tmpl"),
    allow_files=True,
    single_file=True,
  ),
}

_build_attrs = _base_build_attrs + {
  "tag": attr.string(mandatory = True),
  "base": attr.string(mandatory = True),
  "files": attr.string_dict(),
  "entrypoint": attr.string_list(),
  "cmd": attr.string_list(),
  "ports": attr.string_list(),
  "env": attr.string_dict(),
  "registry": attr.string(mandatory = True),
  #TODO: Take effect.
  "stamp": attr.bool(default = False),
}

_build_outputs = {
    "out": "%{name}.id",
    "dockerfile": "Dockerfile.%{name}",
}

build = rule(
  attrs = _build_attrs,
  outputs = _build_outputs,
  # TODO: Return something to not have to run pull unless something change.
  implementation = _build_impl,
)

build_image = struct(
  attrs = _base_build_attrs,
  outputs = _build_outputs,
  implementation = _build_impl,
)

def _pull_impl(ctx):
  result = ctx.execute([
    ctx.path(ctx.attr._script),
    "pull",
    "--registry", ctx.attr.registry,
    "--repository", ctx.attr.repository,
    "--tag", ctx.attr.tag,
  ])

  if result.return_code:
    fail("docker pull failed: %s (%s)" % (result.stdout, result.stderr))


pull = repository_rule(
  attrs = {
    "registry": attr.string(mandatory = True),
    "repository": attr.string(mandatory = True),
    "tag": attr.string(mandatory = True),
    "_script": attr.label(
        executable = True,
        default = Label("//tools:docker.par"),
        cfg = "host",
    ),
  },
  # TODO: Return something to not have to run pull unless something change.
  implementation = _pull_impl,
)
