defmodule Platform.CoreTest do
  use Platform.DataCase

  alias Platform.Core.Schema.Presentation
  alias Platform.Core

  doctest Platform.Core

  describe "presentations" do

    #@valid_attrs %{google_presentation_id: "some google_presentation_id", name: "some name", voice_gender: "female", voice_language: "en-US"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{google_presentation_id: nil, name: nil, voice_gender: nil, voice_language: nil}

    def presentation_fixture(_attrs \\ %{}) do
      # {:ok, presentation} =
      #   attrs
      #   |> Enum.into(@valid_attrs)
      #   |> Core.create_presentation()

      # presentation
      Factory.insert(:presentation)
    end

    # test "list_presentations/0 returns all presentations" do
    #   presentation = presentation_fixture()
    #   assert Core.list_presentations() == [presentation]
    # end

    # test "get_presentation!/1 returns the presentation with given id" do
    #   presentation = presentation_fixture()
    #   assert Core.get_presentation!(presentation.id) == presentation
    # end

    # test "create_presentation/1 with valid data creates a presentation" do
    #   assert {:ok, %Presentation{} = presentation} = Core.create_presentation(@valid_attrs)
    #   assert presentation.google_presentation_id == "some google_presentation_id"
    #   assert presentation.name == "some name"
    #   assert presentation.voice_gender == "female"
    #   assert presentation.voice_language == "en-US"
    # end

    test "create_presentation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_presentation(@invalid_attrs)
    end

    test "update_presentation/2 with valid data updates the presentation" do
      presentation = presentation_fixture()
      assert {:ok, presentation} = Core.update_presentation(presentation, @update_attrs)
      assert %Presentation{} = presentation
      assert presentation.name == "some updated name"
    end

    # test "update_presentation/2 with invalid data returns error changeset" do
    #   presentation = presentation_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Core.update_presentation(presentation, @invalid_attrs)
    #   assert presentation == Core.get_presentation!(presentation.id)
    # end

    test "delete_presentation/1 deletes the presentation" do
      presentation = presentation_fixture()
      assert {:ok, %Presentation{}} = Core.delete_presentation(presentation)
      assert_raise Ecto.NoResultsError, fn -> Core.get_presentation!(presentation.id) end
    end

    test "change_presentation/1 returns a presentation changeset" do
      presentation = presentation_fixture()
      assert %Ecto.Changeset{} = Core.change_presentation(presentation)
    end
  end
end
