defmodule Platform.Accounts.UserFromGoogleAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  alias Ueberauth.Auth
  alias Platform.Accounts

  @behaviour Platform.Accounts.UserFromAuth

  def find_or_create(%Auth{provider: :google} = auth) do
    changes = %{
      google_uid: auth.uid,
      email: auth.info.email,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      image_url: auth.info.image
    }

    model =
      case Accounts.get_user_by_email(auth.info.email) do
        nil -> Accounts.create_user(changes)
        user -> {:ok, user}
      end

    model
  end

  defmacro __using__ do
    quote do
      # handles request action
      plug(Ueberauth)
    end
  end
end
