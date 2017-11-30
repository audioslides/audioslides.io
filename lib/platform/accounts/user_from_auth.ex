defmodule Platform.Accounts.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  @callback find_or_create(%{}) :: {:ok, String.t()} | {:error, String.t()}
end
