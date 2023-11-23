Mox.defmock(SystemEnvMock, for: ElixirScript.Behaviours.SystemEnvBehaviour)
Application.put_env(:context, :system_env, SystemEnvMock)

ExUnit.start()
