defmodule PlatformWeb.CanHelperTest do
  use PlatformWeb.ConnCase
  import PlatformWeb.CanHelper
  import Mock

  alias Platform.Accounts.Schema.User

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(PlatformWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  describe "can? with :atom as model" do
    test "should check allow admin all actions", %{conn: conn} do
      user = Factory.insert(:user, admin: true)
      conn = %{conn | assigns: %{current_user: user}}

      assert can?(conn, :action, :user) == true
    end

    test "should check disallow users all actions", %{conn: conn} do
      user = Factory.insert(:user, admin: false)
      conn = %{conn | assigns: %{current_user: user}}

      assert can?(conn, :action, :user) == false
    end
  end

  describe "can? with struct as model" do
    test "should check allow admin all actions", %{conn: conn} do
      user = Factory.insert(:user, admin: true)
      conn = %{conn | assigns: %{current_user: user}}

      assert can?(conn, :action, %User{}) == true
    end

    test "should check disallow users all actions", %{conn: conn} do
      user = Factory.insert(:user, admin: false)
      conn = %{conn | assigns: %{current_user: user}}

      assert can?(conn, :action, %User{}) == false
    end
  end

  describe "authorize!" do
    test "should return the model if admin", %{conn: conn} do
      user = Factory.insert(:user, admin: true)
      conn = %{conn | assigns: %{current_user: user}}

      assert authorize!(user, conn, :action) == user
    end

    test "should check disallow users all actions", %{conn: conn} do
      user = Factory.insert(:user, admin: false)
      conn = %{conn | assigns: %{current_user: user}}

      conn = authorize!(user, conn, :action)

      assert get_flash(conn, :error) == "You can't access that page!"
      assert redirected_to(conn) == "/"
    end
  end

  describe "authorize_action!" do
    test "should check for private_phoenix_action and map :create to :new", %{conn: conn} do
      with_mock Platform.Ability, [:passthrough], [] do
        user = Factory.insert(:user, admin: true)
        conn = %{conn | assigns: %{current_user: user}}
        conn = %{conn | private: %{phoenix_action: :create}}

        assert authorize_action!(user, conn) == user
        assert called(Platform.Ability.can?(conn.assigns.current_user, :new, user))
      end
    end

    test "should check for private_phoenix_action and map :update to :edit", %{conn: conn} do
      with_mock Platform.Ability, [:passthrough], [] do
        user = Factory.insert(:user, admin: true)
        conn = %{conn | assigns: %{current_user: user}}
        conn = %{conn | private: %{phoenix_action: :update}}

        assert authorize_action!(user, conn) == user
        assert called(Platform.Ability.can?(conn.assigns.current_user, :edit, user))
      end
    end

    test "should check for private_phoenix_action", %{conn: conn} do
      with_mock Platform.Ability, [:passthrough], [] do
        user = Factory.insert(:user, admin: true)
        conn = %{conn | assigns: %{current_user: user}}
        conn = %{conn | private: %{phoenix_action: :some_other_action}}

        assert authorize_action!(user, conn) == user
        assert called(Platform.Ability.can?(conn.assigns.current_user, :some_other_action, user))
      end
    end

    test "should disallow non-admins everything", %{conn: conn} do
      user = Factory.insert(:user, admin: false)
      conn = %{conn | assigns: %{current_user: user}}
      conn = %{conn | private: Map.merge(conn.private, %{phoenix_action: :update})}

      conn = authorize_action!(user, conn)

      assert get_flash(conn, :error) == "You can't access that page!"
      assert redirected_to(conn) == "/"
    end
  end
end
