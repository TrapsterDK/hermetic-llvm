"""Tests that the static and shared sanitizer runtimes share one internal symbolizer build."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _static_impl(_settings, _attr):
    return {"//runtimes:linkmode": "static"}

def _dynamic_impl(_settings, _attr):
    return {"//runtimes:linkmode": "dynamic"}

_static_transition = transition(
    implementation = _static_impl,
    inputs = [],
    outputs = ["//runtimes:linkmode"],
)

_dynamic_transition = transition(
    implementation = _dynamic_impl,
    inputs = [],
    outputs = ["//runtimes:linkmode"],
)

LinkmodeRootsInfo = provider(
    doc = "Output roots of the same target reached under each runtime linkmode.",
    fields = ["dynamic", "static"],
)

def _linkmode_roots_impl(ctx):
    return [LinkmodeRootsInfo(
        dynamic = ctx.files.dynamic[0].root.path,
        static = ctx.files.static[0].root.path,
    )]

linkmode_roots = rule(
    implementation = _linkmode_roots_impl,
    attrs = {
        "dynamic": attr.label(cfg = _dynamic_transition),
        "static": attr.label(cfg = _static_transition),
    },
)

def _internal_symbolizer_linkmode_test_impl(ctx):
    env = analysistest.begin(ctx)
    roots = analysistest.target_under_test(env)[LinkmodeRootsInfo]
    asserts.equals(env, roots.static, roots.dynamic)
    return analysistest.end(env)

internal_symbolizer_linkmode_test = analysistest.make(_internal_symbolizer_linkmode_test_impl)
