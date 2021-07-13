# Missing bazel-testlogs with starlark transitions

This is a minimal bug reproduction based on the bazel test rule example https://github.com/bazelbuild/examples/tree/fe9b9cc4fa7eb4335f3409bbb2d4806fb1201bdf/rules/test_rule

Bug filed https://github.com/bazelbuild/bazel/issues/13674

## The bug 

We expect a test target with an incoming edge transition would behave the same as one without an incoming edge transition.

When running these two targets, we expect to see the test outputs under bazel-testlogs.

```
//:80columns_with_transition
//:80columns
```

However, we only see testlogs for `//:80columns`. 

```
bazel test //...

tree bazel-testlogs

bazel-testlogs
└── 80columns
    ├── test.cache_status
    ├── test.log
    ├── test.outputs
    ├── test.outputs_manifest
    ├── test.raw_splitlogs
    └── test.xml
```

We should have seen the same outputs for the transition test, but nothing was copied.

You can also reproduce the issue by running only the test target bazel test //:80columns_with_transition and seeing that bazel-testlogs does not have anything from that target.
