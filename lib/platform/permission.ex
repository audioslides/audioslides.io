defmodule Platform.Permission do
  @moduledoc """
  Defines all access rights for all models. White listing approach.
  """
  alias Platform.Accounts.Schema.User
  alias Platform.Core.Schema.Lesson

  # Admin
  def can?(%User{admin: true}, _action, _model), do: true

  # Visitor without login
  def can?(_everybody, :index, %Lesson{}), do: true
  def can?(_everybody, :show, %Lesson{}), do: true

  # Else no access. Define via whitelisting not blacklisting
  def can?(_everybody, _action, _model), do: false
end
