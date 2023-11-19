defmodule SystemEnvImpl do
  @moduledoc """
  An implementation of SystemEnvBehaviour by proxying into System
  """

  @behaviour SystemEnvBehaviour

  @impl SystemEnvBehaviour
  def get_env do
    System.get_env()
  end

  @impl SystemEnvBehaviour
  def get_env(varname, default \\ nil) do
    System.get_env(varname, default)
  end
end
