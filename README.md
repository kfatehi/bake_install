# cross-platform bake installer

Designed to work on mac, windows, and linux

``` 
elixir -e "case ~s(https://rawgit.com/kfatehi/bake_install/master/install.exs) |> Mix.Utils.read_path(sha512: ~s(aac24d2c96537fb70585a5e0395381db7120bd6174fc005e5e0c79356547fcd63ade50b61377729a4f4271590aca44896ad1184752f1cc64348ca6f48a7ceb92)) do {:ok, code} -> code end |> Code.eval_string()"
```
