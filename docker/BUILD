package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load("@tools_deps//:requirements.bzl", "all_requirements")
load("@io_bazel_rules_python//python:python.bzl", "py_library")
load("@subpar//:subpar.bzl", "par_binary")

py_library(
    name = "default_library",
    srcs = glob(["src/**/*.py"]),
    deps = all_requirements,
)

par_binary(
    name = "docker",
    srcs = glob(["src/**/*.py"]),
    main = "src/main.py",
    deps = [
        ":default_library",
    ],
)
