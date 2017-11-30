defmodule Platform.Permission do
  @moduledoc """
  Defines all access rights for all models. White listing approach.
  """
  alias Platform.Accounts.Schema.User

  # Admin
  def can?(%User{admin: true}, _, _), do: true

  # Else
  def can?(_, _, _), do: false
end
