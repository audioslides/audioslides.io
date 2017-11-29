defmodule Platform.Accounts.UserFromGoogleAuthTest do
  use Platform.DataCase

  alias Platform.Accounts.UserFromGoogleAuth
  alias Ueberauth.Auth

  describe "#find_or_create" do
    test "google - creates a user when exists" do
      demo_user = Factory.insert(:user)

      auth = %Auth{
        provider: :google,
        uid: String.to_integer(demo_user.google_uid),
        info: %{
          first_name: demo_user.first_name,
          last_name: demo_user.last_name,
          email: demo_user.email,
          image: demo_user.image_url
        }
      }
      {:ok, user} = UserFromGoogleAuth.find_or_create(auth)

      assert user.first_name == demo_user.first_name
      assert user.email == demo_user.email
      assert user.google_uid == demo_user.google_uid
    end

    test "google - creates a user when NOT exists with first/last name" do
      auth = %Auth{
        provider: :google,
        uid: "1123432",
        info: %{
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com",
          image: "profile.png"
        }
      }
      {:ok, user} = UserFromGoogleAuth.find_or_create(auth)

      assert user.first_name == "John"
      assert user.email == "john@example.com"
      assert user.google_uid == "1123432"
    end
  end
end
