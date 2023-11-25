Mox.defmock(SystemEnvMock, for: ElixirScript.Behaviours.SystemEnvBehaviour)
Application.put_env(:context, :system_env, SystemEnvMock)

# # #

Mox.defmock(TentacatMock.ClientMock,
  for: ElixirScript.Behaviours.TentacatBehaviour.ClientBehaviour
)

Application.put_env(:script_runner, :tentacat_client, TentacatMock.ClientMock)

# # #

Mox.defmock(ElixirScript.ScriptRunnerMock, for: ElixirScript.ScriptRunnerBehaviour)
Application.put_env(:command_line, :script_runner, ElixirScript.ScriptRunnerMock)

# # #

ExUnit.start()
