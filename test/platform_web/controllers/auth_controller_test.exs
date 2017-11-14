defmodule PlatformWeb.AuthControllerTest do
  use PlatformWeb.ConnCase

  describe "#callback" do
    test "when callback fails", %{conn: conn} do
      conn = get conn, auth_path(conn, :callback, "google")

      assert get_flash(conn, :error) == "Failed to authenticate."
      assert redirected_to(conn) == "/"
    end

    # test "when callback succeeds", %{conn: conn} do
    #   conn = assign(conn, :ueberauth_auth, %{})

    #   conn = get conn, auth_path(conn, :callback, "google")

    #   assert get_flash(conn, :info) == "Successfully authenticated."
    #   assert redirected_to(conn) == "/"
    # end
  end
end
