defmodule Platform.Accounts.Schema.User do
  @moduledoc """
  The user schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:google_uid, :string)
    field(:image_url, :string)
    field(:admin, :boolean, default: false)
    timestamps()

    has_many(:lessons, Platform.Core.Schema.Lesson, on_delete: :delete_all)
  end

  @doc false
  @fields [:email, :first_name, :last_name, :google_uid, :image_url]
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:email, :first_name, :last_name, :google_uid])
    |> unique_constraint(:email)
  end
end
