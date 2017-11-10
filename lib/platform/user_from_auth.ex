defmodule Platform.Accounts.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  alias Ueberauth.Auth
  alias Platform.Accounts

  def find_or_create(%Auth{provider: :google} = auth) do
    changes = %{
       google_uid: auth.uid,
       email: auth.info.email,
       first_name: auth.info.first_name,
       last_name: auth.info.last_name,
       image_url: auth.info.image
    }

    model = case Accounts.get_user_by_email(auth.info.email) do
      nil  -> Accounts.create_user(changes)
      user -> {:ok, user}
    end

    model
  end
end
