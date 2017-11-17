defmodule PlatformWeb.AuthControllerTest do
  use PlatformWeb.ConnCase

  alias Ueberauth.Auth

  import Mock

  describe "#callback" do
    test "when callback fails", %{conn: conn} do
      conn = get conn, auth_path(conn, :callback, "google")

      assert get_flash(conn, :error) == "Failed to authenticate."
      assert redirected_to(conn) == "/"
    end

    test "when callback succeeds", %{conn: conn} do
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

      conn = assign(conn, :ueberauth_auth, auth)
      conn = get conn, auth_path(conn, :callback, "google")

      assert get_flash(conn, :info) == "Successfully authenticated."
      assert redirected_to(conn) == "/"
    end

    test "when callback succeeds but error", %{conn: conn} do
      with_mock Platform.Accounts.UserFromAuth, [find_or_create: fn _ -> {:error, "some reason"} end] do
        demo_user = Factory.insert(:user)
        auth = %Auth{
          provider: :google,
          uid: 1234, # provoke an error here
          info: %{
            first_name: demo_user.first_name,
            last_name: demo_user.last_name,
            email: demo_user.email,
            image: demo_user.image_url
          }
        }

        conn = assign(conn, :ueberauth_auth, auth)
        conn = get conn, auth_path(conn, :callback, "google")

        assert get_flash(conn, :error) == "some reason"
        assert redirected_to(conn) == "/"
      end
    end
  end

  describe "#delete" do
    test "logout successfull", %{conn: conn} do
      conn = delete conn, auth_path(conn, :delete)

      assert get_flash(conn, :info) == "You have been logged out!"
      assert redirected_to(conn) == "/"
    end

    test "when callback succeeds", %{conn: conn} do
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

      conn = assign(conn, :ueberauth_auth, auth)
      conn = get conn, auth_path(conn, :callback, "google")

      assert redirected_to(conn) == "/"
    end
  end
end
