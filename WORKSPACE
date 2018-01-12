workspace(name = "io_bazel_docker_rules")

git_repository(
    name = "subpar",
    remote = "https://github.com/google/subpar",
    tag = "1.1.0",
)

git_repository(
    name = "io_bazel_rules_python",
    remote = "https://github.com/bazelbuild/rules_python.git",
    commit = "f2e01f91c3655885e5532d14ab4d2bcd197ebd07",
)
load("@io_bazel_rules_python//python:pip.bzl", "pip_repositories")
pip_repositories()

load("@io_bazel_rules_python//python:pip.bzl", "pip_import")
pip_import(
   name = "tools_deps",
   requirements = "//docker:requirements.txt",
)
load("@tools_deps//:requirements.bzl", "pip_install")
pip_install()
