defmodule Platform.AccountsTest do
  use Platform.DataCase

  alias Platform.Accounts

  describe "users" do
    alias Platform.Accounts.Schema.User

    @valid_attrs Factory.params_for(:user)
    @update_attrs %{first_name: "John", last_name: "Doe"}
    @invalid_attrs %{first_name: ""}

    test "paginate_users/1 returns all users" do
      Factory.insert(:user)
      # assert %Scrivener.Page{entries: [_user]} = Accounts.paginate_users(%{})
    end

    test "get_user!/1 returns the user with given id" do
      user = Factory.insert(:user)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "get_user/1 returns the user with given id" do
      user = Factory.insert(:user)
      assert Accounts.get_user(user.id).id == user.id
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = Factory.insert(:user)
      assert Accounts.get_user_by_email(user.email).id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.first_name == @valid_attrs.first_name
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = Factory.insert(:user)
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.first_name == @update_attrs.first_name
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = Factory.insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user.id == Accounts.get_user!(user.id).id
    end

    test "delete_user/1 deletes the user" do
      user = Factory.insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = Factory.insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
