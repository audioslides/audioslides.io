defmodule Platform.Accounts do
  @moduledoc """
  The Accounts context. Everything that belongs to a user.
  The user model itself and e.g. user favorites, settings, etc.
  """
  import Ecto.Query, warn: false

  alias Platform.Accounts.Schema.User
  alias Platform.Repo

  ### ################################################################### ###
  ### User                                                                ###
  ### ################################################################### ###
  def get_user!(id) do
    User
    |> Repo.get!(id)
  end

  def get_user(id) do
    User
    |> Repo.get(id)
  end

  def get_user_by_email(email) do
    User
    |> Repo.get_by(email: email)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
