# Download, Verify and Execute on all Platforms

```
# good checksum
$ elixir -e "case ~s(https://rawgit.com/kfatehi/bake_install/master/install.exs) |> Mix.Utils.read_path(sha512: ~s(1714c3857fcd96227d4dedc0cfdff050a9fcec00470ed64917216e24239a2d6e410fad3747ca4b5fabfa0a30ba38430f2a90755009d559fe96e8ec5b1e06124f)) do {:ok, code} -> code end |> Code.eval_string()"
helo wordl

#bad checksum
$ elixir -e "case ~s(http://localhost:8000/install.exs) |> Mix.Utils.read_path(sha512: ~s(123)) do {:ok, code} -> code end |> Code.eval_string()"
** (CaseClauseError) no case clause matching: {:checksum, "Data does not match the given sha512 checksum.\n\nExpected: 123\n  Actual: 45b8ba592d816dbe56e58aaacf6378e9509a16acd3654f39ce7ee04af8696d0cc365f0a9aeee779d22506b8a5ca9590d1176df6dbabaf1477d16bfb25a2e0dd8\n"}
    (stdlib) :erl_eval.expr/3
    (elixir) lib/code.ex:168: Code.eval_string/3
```

# get checksum

curl -L https://rawgit.com/kfatehi/bake_install/master/install.exs | shasum -a 512


# windows untar

http://stackoverflow.com/a/29663095
