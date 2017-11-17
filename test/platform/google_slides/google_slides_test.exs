defmodule Platform.GoogleSlidesTest do
  @moduledoc """
  Test GoogleSlide functions and mock external API
  """
  use ExUnit.Case

  import Mock

  alias Goth.Token
  alias GoogleApi.Slides.V1.Api.Presentations
  alias GoogleApi.Slides.V1.Connection
  alias GoogleApi.Slides.V1.Model.Page
  alias GoogleApi.Slides.V1.Model.PageElement
  alias Platform.FileHelper

  import Platform.GoogleSlidesFactory
  import Platform.GoogleSlides

  doctest Platform.GoogleSlides

  setup_with_mocks([
      {Presentations, [], [
        slides_presentations_get: fn _con, _presentation_id, _opts -> {:ok, %{}} end,
        slides_presentations_pages_get: fn _con, _presentation_id, _slide_id -> {:ok, %{}} end,
        slides_presentations_pages_get_thumbnail: fn _con, _presentation_id, _slide_id -> {:ok, %{contentUrl: "https://some.content/for/you.png"}} end,

        ]},
      {Connection, [], [new: fn _ -> %{} end]},
      {Token, [], [for_scope: fn _ -> {:ok, %{token: "SUPER_TOKEN"}} end]},
      {FileHelper, [], [write_to_file: fn _, _ -> {:ok, "mock file written"} end]},
      {HTTPoison, [], [get!: fn _url -> %HTTPoison.Response{body: "data"} end]}
    ])
    do
    {:ok, nothing: "yes"}
  end

  describe "get_presentation!" do
    test "should get a presentation via GoogleAPI" do
      get_presentation!("1")

      assert called Presentations.slides_presentations_get(:_, "1", :_)
    end
  end

  describe "get_slide!" do
    test "should get a slide via GoogleAPI" do
      get_slide!("presentation_id","slide_id")

      assert called Presentations.slides_presentations_pages_get(:_, "presentation_id", "slide_id")
    end
  end

  describe "get_slide_thumb!" do
    test "should get a slide via GoogleAPI" do
      get_slide_thumb!("presentation_id","slide_id")

      assert called Presentations.slides_presentations_pages_get_thumbnail(:_, "presentation_id", "slide_id")
    end
  end

  describe "download_slide_thumb!" do
    test "should get a slide via GoogleAPI" do
      download_slide_thumb!("presentation_id","slide_id", "file/name/example.png")

      assert called FileHelper.write_to_file("file/name/example.png", "data")
    end
  end

end
