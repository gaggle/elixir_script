defmodule Test.Fixtures.GitHubWorkflowRun do
  @moduledoc """
  Fixture for a GitHub Workflow run
  """
  @context_event_path "test/fixtures/github_workflow_run_context_event.json"

  def env do
    %{
      "GITHUB_BASE_REF" => "",
      "GITHUB_REPOSITORY_ID" => "675841662",
      "GITHUB_ACTION_REF" => "v0",
      "GITHUB_EVENT_PATH" => @context_event_path,
      "GITHUB_PATH" => "/github/file_commands/add_path",
      "CI" => "true",
      "GITHUB_WORKSPACE" => "/github/workspace",
      "GITHUB_RUN_ATTEMPT" => "1",
      "GITHUB_OUTPUT" => "/github/file_commands/set_output",
      "GITHUB_REF" => "refs/heads/main",
      "GITHUB_REF_PROTECTED" => "false",
      "GITHUB_WORKFLOW_REF" =>
        "gaggle/elixir_script/.github/workflows/examples.yml@refs/heads/main",
      "GITHUB_STEP_SUMMARY" => "/github/file_commands/step_summary",
      "GITHUB_ACTOR_ID" => "2316447",
      "GITHUB_TRIGGERING_ACTOR" => "gaggle",
      "GITHUB_JOB" => "event-context-is-available",
      "GITHUB_WORKFLOW_SHA" => "77cefc59a7095f6b86508e8e26ff9f866da4b5e5",
      "GITHUB_API_URL" => "https://api.github.com",
      "GITHUB_ACTION" => "script",
      "GITHUB_REPOSITORY" => "gaggle/elixir_script",
      "GITHUB_ENV" => "/github/file_commands/set_env",
      "GITHUB_REPOSITORY_OWNER_ID" => "2316447",
      "GITHUB_SERVER_URL" => "https://github.com",
      "GITHUB_REF_TYPE" => "branch",
      "GITHUB_GRAPHQL_URL" => "https://api.github.com/graphql",
      "GITHUB_REF_NAME" => "main",
      "GITHUB_ACTOR" => "gaggle",
      "GITHUB_RUN_NUMBER" => "15",
      "GITHUB_SHA" => "77cefc59a7095f6b86508e8e26ff9f866da4b5e5",
      "GITHUB_RUN_ID" => "6922972178",
      "GITHUB_RETENTION_DAYS" => "90",
      "GITHUB_STATE" => "/github/file_commands/save_state",
      "GITHUB_ACTIONS" => "true",
      "GITHUB_WORKFLOW" => "Examples",
      "GITHUB_REPOSITORY_OWNER" => "gaggle",
      "GITHUB_EVENT_NAME" => "push",
      "GITHUB_ACTION_REPOSITORY" => "gaggle/elixir_script",
      "GITHUB_HEAD_REF" => ""
    }
  end
end
