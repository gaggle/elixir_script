defmodule ElixirScript.Behaviours.TentacatBehaviour.ClientBehaviour do
  @moduledoc """
  Abstract behaviour of Tentacat
  """
  @callback new() :: Tentacat.Client.t()
  @callback new(%{access_token: binary()}) :: Tentacat.Client.t()
end
