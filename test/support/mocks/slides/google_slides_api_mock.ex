defmodule Platform.GoogleSlidesAPIMock do
  @moduledoc """
  The google slides mock context
  """

  @behaviour Platform.SlideAPI

  def get_presentation(presentation_id) when is_binary(presentation_id) do
    {:ok, {}}
  end

  def get_slide!(_presentation_id, _slide_id) do
    {}
  end

  def get_slide_thumb!(_presentation_id, _slide_id) do
    {}
  end

  def download_slide_thumb!(_presentation_id, _slide_id, filename) do
    filename
  end

end
