defmodule ElixirScript.Behaviours.TentacatBehaviour.ClientBehaviour do
  @callback new() :: Tentacat.Client.t()
  @callback new(%{access_token: binary()}) :: Tentacat.Client.t()
end
