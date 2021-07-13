"""Test rule that fails if a source file has too long lines."""

def _check_file(f, columns):
    """Return shell commands for testing file 'f'."""

    # We write information to stdout. It will show up in logs, so that the user
    # knows what happened if the test fails.
    return """
echo Testing that {file} has at most {columns} columns...
grep -E '^.{{{columns}}}' {path} && err=1
echo
""".format(columns = columns, path = f.path, file = f.short_path)

def _impl(ctx):
    script = "\n".join(
        ["err=0"] +
        [_check_file(f, ctx.attr.columns) for f in ctx.files.srcs] +
        ["exit $err"],
    )

    # Write the file, it is executed by 'bazel test'.
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
    )

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.
    runfiles = ctx.runfiles(files = ctx.files.srcs)
    return [DefaultInfo(runfiles = runfiles)]

def _some_incoming_transition_impl(settings, attr):
    settings = dict(settings)

    if attr.foo == "bar":
        settings["//:foo"] = "bar"
    elif attr.foo == "baz":
        settings["//:foo"] = "baz"

    return settings

some_incoming_transition = transition(
    implementation = _some_incoming_transition_impl,
    inputs = [
        "//:foo",
    ],
    outputs = [
        "//:foo",
    ],
)

line_length_test = rule(
    implementation = _impl,
    attrs = {
        "columns": attr.int(default = 100),
        "srcs": attr.label_list(allow_files = True),
        "foo": attr.string(values = ["bar", "baz"]),
        "_whitelist_function_transition": attr.label(
            default = "@bazel_tools//tools/whitelists/function_transition_whitelist",
        ),
    },
    cfg = some_incoming_transition,
    test = True,
)