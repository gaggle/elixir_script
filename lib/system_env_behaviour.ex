defmodule SystemEnvBehaviour do
  @moduledoc """
  The abstract behaviour of SystemEnvBehaviour
  """
  @callback get_env() :: %{optional(String.t()) => String.t()}
  @callback get_env(String.t(), String.t() | nil) :: String.t() | nil
end
