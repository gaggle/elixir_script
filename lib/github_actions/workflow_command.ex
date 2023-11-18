defmodule ElixirScript.GitHubActions.WorkflowCommand do
  @moduledoc """
  Handles GitHub Actions Workflow Commands.

  This module is designed to interact with GitHub Actions by issuing
  workflow commands as specified in the GitHub Actions documentation:
  [Workflow Commands for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#about-workflow-commands).
  """

  def issue_command(command, name, command_value) do
    IO.puts("::#{command} name=#{name}::#{command_value}")
  end
end
