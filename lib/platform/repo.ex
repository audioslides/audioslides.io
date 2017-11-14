defmodule Platform.Repo do
  use Ecto.Repo, otp_app: :platform

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc """
  Sets a field to the current time in utc.
  Default field is :inserted_at
  """
  def touch_utc!(%{__struct__: _} = data, field, now \\ DateTime.utc_now()) when is_atom(field) do
    update_map = Map.put(%{}, field, now)

    data
    |> Ecto.Changeset.change(update_map)
    |> update!()
  end
end
