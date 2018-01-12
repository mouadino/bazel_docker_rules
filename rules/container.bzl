load("//rules:image.bzl", "build_image")

container = struct(
    build = build_image,
)
