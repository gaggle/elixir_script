Mox.defmock(SystemEnvBehaviourMock, for: SystemEnvBehaviour)
Application.put_env(:context, :system_env, SystemEnvBehaviourMock)

ExUnit.start()
