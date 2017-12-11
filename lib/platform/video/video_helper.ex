defmodule Platform.VideoHelper do
  @moduledoc """
  Context for the video converter
  """
  require Logger

  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  @doc """
  iex> sha256("TEST")
  "94EE059335E587E501CC4BF90613E0814F00A7B08BC7C648FD865A2AF6A22CC2"

  iex> sha256("")
  "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  """
  def sha256(data) do
    sha_hash = :crypto.hash(:sha256, data)
    Base.encode16(sha_hash)
  end

  @doc """

  iex> generate_video_hash(nil)
  nil

  iex> generate_video_hash(%Slide{audio_hash: "A", image_hash: "B"})
  "38164FBD17603D73F696B8B4D72664D735BB6A7C88577687FD2AE33FD6964153"

  iex> generate_video_hash(%Slide{audio_hash: "A", image_hash: "A"})
  "58BB119C35513A451D24DC20EF0E9031EC85B35BFC919D263E7E5D9868909CB5"

  """
  def generate_video_hash(%Slide{audio_hash: audio_hash, image_hash: image_hash})
      when is_binary(audio_hash) and is_binary(image_hash) do
    "#{audio_hash}#{image_hash}"
    |> sha256()
  end
  def generate_video_hash(%Lesson{slides: slides}) when is_list(slides) do
    slides
    |> Enum.map(fn slide -> slide.video_hash end)
    |> Enum.join
    |> sha256()
  end
  def generate_video_hash(_), do: nil

end
