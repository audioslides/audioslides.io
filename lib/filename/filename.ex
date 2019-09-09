defmodule Filename do
  @moduledoc """
  Context for all filenames for IO
  """

  @content_dir Application.get_env(:platform, :content_dir)

  @doc """

  iex> get_filename_for_lesson_video(%{id: 1})
  "priv/static/content/1.mp4"

  iex> get_filename_for_lesson_video(%{id: 2})
  "priv/static/content/2.mp4"

  """
  def get_filename_for_lesson_video(%{} = lesson) do
    "#{@content_dir}#{lesson.id}.mp4"
  end

  @doc """

  iex> get_filename_for_slide_video(%{id: 1}, %{id: 2})
  "priv/static/content/1/2.mp4"

  iex> get_filename_for_slide_video(%{id: 3}, %{id: 9})
  "priv/static/content/3/9.mp4"
  """
  def get_filename_for_slide_video(%{} = lesson, %{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.mp4"
  end


  @doc """

  iex> contains_text_video?("Normal Text")
  false

  iex> contains_text_video?("<video>Video Source</video>")
  true

  """
  defp contains_text_video?(text) do
    Regex.run(@video_ssml, text)
  end

  @doc """

  iex> get_relative_filename_for_slide_video(%{id: 1}, %{id: 2})
  "1/2.mp4"

  iex> get_relative_filename_for_slide_video(%{id: 3}, %{id: 9})
  "3/9.mp4"
  """
  def get_relative_filename_for_slide_video(%{} = lesson, %{} = slide) do
    "#{lesson.id}/#{slide.id}.mp4"
  end

  @doc """

  iex> get_filename_for_slide_image(%{id: 3}, %{id: 9})
  "priv/static/content/3/9.png"

  iex> get_filename_for_slide_image(%{id: 1}, %{id: 2})
  "priv/static/content/1/2.png"
  """
  def get_filename_for_slide_image(%{} = lesson, %{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.png"
  end

  @doc """

  iex> get_filename_for_slide_audio(%{id: 1}, %{id: 2})
  "priv/static/content/1/2.wav"

  iex> get_filename_for_slide_audio(%{id: 3}, %{id: 7})
  "priv/static/content/3/7.wav"
  """
  def get_filename_for_slide_audio(%{} = lesson, %{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.wav"
  end

  @doc """

  iex> get_directory_for_lesson(%{id: 1})
  "priv/static/content/1"

  iex> get_directory_for_lesson(%{id: 2})
  "priv/static/content/2"
  """
  def get_directory_for_lesson(%{} = lesson) do
    "#{@content_dir}#{lesson.id}"
  end

  @doc """

  iex> get_filename_for_ffmpeg_concat()
  "priv/static/content/ffmpeg_concat_temporary.txt"
  """
  def get_filename_for_ffmpeg_concat do
    "#{@content_dir}ffmpeg_concat_temporary.txt"
  end
end
