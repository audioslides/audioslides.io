defmodule PlatformWeb.PageController do
  use PlatformWeb, :controller

  def index(conn, _params) do
    # works! :)
    # Platform.Converter.merge_audio_image(
    #   audio_filename: "test/support/fixtures/slide.mp3",
    #   image_filename: "test/support/fixtures/slide.png",
    #   out_filename: "test/support/fixtures/slide.mp4",
    # )

    render conn, "index.html"
  end
end
