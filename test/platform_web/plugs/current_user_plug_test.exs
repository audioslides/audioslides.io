defmodule PlatformWeb.CurrentUserPlugTest do
  use PlatformWeb.ConnCase
  use Plug.Test

  alias PlatformWeb.CurrentUserPlug

  import Mock

  describe "#init" do
    test "passes the options unmodified" do
      opts = %{test: 123}
      assert CurrentUserPlug.init(opts) == opts
    end
  end

  describe "#call" do
    test "assigns user and token when user_id is given", %{conn: conn} do
      with_mock Phoenix.Token, sign: fn _, _, _ -> "MYTOKEN" end do
        user = Factory.insert(:user)

        # raises ** (ArgumentError) session not fetched, call fetch_session/2
        conn =
          conn
          |> init_test_session(%{user_id: user.id})
          |> put_session(:user_id, user.id)
          |> CurrentUserPlug.call([])

        assert conn.assigns.current_user.id == user.id
        assert conn.assigns.user_token == "MYTOKEN"
      end
    end

    test "assigns user and token when current_user is given", %{conn: conn} do
      with_mock Phoenix.Token, sign: fn _, _, _ -> "MYTOKEN" end do
        user = Factory.insert(:user)
        conn = %{conn | assigns: %{current_user: user}}

        conn =
          conn
          |> CurrentUserPlug.call([])

        assert conn.assigns.current_user.id == user.id
        assert conn.assigns.user_token == "MYTOKEN"
      end
    end
  end
end
