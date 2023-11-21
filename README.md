# ElixirScript

This action makes it easy to quickly write and execute an Elixir script in your workflow.

To use this action, provide an input named `script` that contains Elixir code:

```yaml
- uses: gaggle/elixir_script@v0
  with:
    script: |
      IO.puts("Magic, just like the potions in Elixir ✨")
```

### Bindings

The following arguments are available in the script's bindings:

* `context`: A map containing the context of the workflow run.
  It can be accessed like this:
  ```yaml
  script: |
    "🚀 Pushed to #{context.payload.repository.name} by @#{context.actor}! 
  ```

_These bindings are already defined,
so you don't have to import them._

### Outputs

The return value of the script will be in the step's `outputs.result`:

```yaml
- uses: gaggle/elixir_script@v0
  id: script
  with:
    script: |
      "Oh hi Mark!"

- name: Get result
  run: echo "${{steps.script.outputs.result}}"
```

See [.github/workflows/examples.yml](.github/workflows/examples.yml) for more examples.

## Acknowledgements

### Inspired by [GitHub Script][github-script]

This Elixir Script action is based on the [GitHub Script action][github-script],
which is primarily built around Javascript.
Elixir Script adapts its interfaces and functionality to the Elixir environment,
aiming to provide a seamless experience for Elixir developers.
Many thanks to the creators and contributors of GitHub Script!

## Releasing

[New releases](https://github.com/gaggle/elixir_script/releases) are automatically created
when [`.pkgx.yaml`](.pkgx.yaml)'s `VERSION` is incremented.
The release must then be edited and then immediately resaved to publish it to the Actions Marketplace

(This is a built-in limitation of GitHub releases
that prevents Marketplace releases from being automated)

[github-script]: https://github.com/marketplace/actions/github-script

[tentacat]: https://github.com/edgurgel/tentacat
