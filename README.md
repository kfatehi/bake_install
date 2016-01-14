# Download, Verify and Execute on all Platforms

```
# good checksum
$ elixir -e "case ~s(http://localhost:8000/install.exs) |> Mix.Utils.read_path(sha512: ~s(45b8ba592d816dbe56e58aaacf6378e9509a16acd3654f39ce7ee04af8696d0cc365f0a9aeee779d22506b8a5ca9590d1176df6dbabaf1477d16bfb25a2e0dd8)) do {:ok, code} -> code end |> Code.eval_string()"
helo wordl

#bad checksum
$ elixir -e "case ~s(http://localhost:8000/install.exs) |> Mix.Utils.read_path(sha512: ~s(123)) do {:ok, code} -> code end |> Code.eval_string()"
** (CaseClauseError) no case clause matching: {:checksum, "Data does not match the given sha512 checksum.\n\nExpected: 123\n  Actual: 45b8ba592d816dbe56e58aaacf6378e9509a16acd3654f39ce7ee04af8696d0cc365f0a9aeee779d22506b8a5ca9590d1176df6dbabaf1477d16bfb25a2e0dd8\n"}
    (stdlib) :erl_eval.expr/3
    (elixir) lib/code.ex:168: Code.eval_string/3
```
