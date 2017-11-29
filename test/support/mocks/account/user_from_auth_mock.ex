defmodule Platform.Accounts.UserFromAuthMock do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  @behaviour Platform.Accounts.UserFromAuth

  def find_or_create(%{}) do
    {:ok, %{}}
  end
end
