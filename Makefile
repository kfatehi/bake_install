URL="https://cdn.jsdelivr.net/gh/kfatehi/bake_install@master/install.exs"

SHASUM:=$(shell shasum -a 512 install.exs | awk '{print $$1}' )

SCRIPT="elixir -e \"case ~s($(URL)) |> Mix.Utils.read_path(sha512: ~s($(SHASUM))) do {:ok, code} -> code end |> Code.eval_string()\""

default: readme

readme:
	@-rm README.md
	@touch README.md
	@echo "# cross-platform bake installer" >> README.md
	@echo "\nDesigned to work on mac, windows, and linux\n" >> README.md
	@echo \`\`\`\ >> README.md
	@echo $(SCRIPT) >> README.md
	@echo \`\`\` >> README.md
	@echo "Updated README.md:\n"
	@cat README.md

