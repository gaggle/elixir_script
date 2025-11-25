# ElixirScript

This action makes it easy to quickly write and execute an Elixir script in your workflow.

To use this action, provide an input named `script` that contains Elixir code:

```yaml
- uses: gaggle/elixir_script@v0
  with:
    script: |
      IO.puts("Magic, just like the potions in Elixir ✨")
```

### Using Script Files

You can also provide a path to an Elixir script file instead of inline code:

```yaml
- uses: actions/checkout@v4
- uses: gaggle/elixir_script@v0
  with:
    script: ./.github/scripts/my_script.exs
```

The action automatically detects if the `script` input is a file path and will read and execute that file:

```elixir
# .github/scripts/my_script.exs
{200, issues, _} = Tentacat.Issues.list(client, "gaggle", "elixir_script")

issues
|> Enum.filter(& &1["state"] == "open")
|> Enum.map(& "- ##{&1["number"]}: #{&1["title"]}")
|> Enum.join("\n")
```

### Bindings

The following arguments are available in the script's bindings:

* `context`: A map containing the context of the workflow run.
  It can be accessed like this:
  ```yaml
  script: |
    "🚀 Pushed to #{context.payload.repository.name} by @#{context.actor}! 
  ```
* `client`: A pre-authenticated [Tentacat][tentacat] GitHub client.
  It can be used like this:
  ```yaml
  script: |
    {200, user, _} = Tentacat.Users.find(client, "gaggle")
    IO.puts("🤔" <> user["name"]) 
  ```
  You can go to the [Tentacat project page][tentacat]
  or read [the project's Hexdocs documentation][tentacat-docs]
  for how to use all its features.

_These bindings are already defined, so you don't have to import them._

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

### Tentacat

The GitHub library is by [Eduardo Gurgel][eduardo],
huge thanks to Eduardo and contributors for making such a useful project available.

## Releasing

[New releases](https://github.com/gaggle/elixir_script/releases) are automatically created
when [`.pkgx.yaml`](.pkgx.yaml)'s `VERSION` is incremented.
The release must then be edited and then immediately resaved to publish it to the Actions Marketplace

(This is a built-in limitation of GitHub releases
that prevents Marketplace releases from being automated)

[eduardo]: https://github.com/edgurgel

[github-script]: https://github.com/marketplace/actions/github-script

[tentacat]: https://github.com/edgurgel/tentacat

[tentacat-docs]: https://hexdocs.pm/tentacat
