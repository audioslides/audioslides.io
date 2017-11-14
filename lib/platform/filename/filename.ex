defmodule Platform.Filename do
  @moduledoc """
  Context for all filenames for IO
  """
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  @content_dir Application.get_env(:platform, :content_dir)

  @doc """

  iex> get_filename_for_lesson_video(%Lesson{id: 1})
  "priv/static/content/1.mp4"

  iex> get_filename_for_lesson_video(%Lesson{id: 2})
  "priv/static/content/2.mp4"

  """
  def get_filename_for_lesson_video(%Lesson{} = lesson) do
    "#{@content_dir}#{lesson.id}.mp4"
  end

  @doc """

  iex> get_filename_for_slide_video(%Lesson{id: 1}, %Slide{id: 2})
  "priv/static/content/1/2.mp4"

  iex> get_filename_for_slide_video(%Lesson{id: 3}, %Slide{id: 9})
  "priv/static/content/3/9.mp4"
  """
  def get_filename_for_slide_video(%Lesson{} = lesson, %Slide{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.mp4"
  end

  @doc """

  iex> get_filename_for_slide_image(%Lesson{id: 3}, %Slide{id: 9})
  "priv/static/content/3/9.png"

  iex> get_filename_for_slide_image(%Lesson{id: 1}, %Slide{id: 2})
  "priv/static/content/1/2.png"
  """
  def get_filename_for_slide_image(%Lesson{} = lesson, %Slide{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.png"
  end

  @doc """

  iex> get_filename_for_slide_audio(%Lesson{id: 1}, %Slide{id: 2})
  "priv/static/content/1/2.mp3"

  iex> get_filename_for_slide_audio(%Lesson{id: 3}, %Slide{id: 7})
  "priv/static/content/3/7.mp3"
  """
  def get_filename_for_slide_audio(%Lesson{} = lesson, %Slide{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.mp3"
  end

  @doc """

  iex> get_directory_for_lesson(%Lesson{id: 1})
  "priv/static/content/1"

  iex> get_directory_for_lesson(%Lesson{id: 2})
  "priv/static/content/2"
  """
  def get_directory_for_lesson(%Lesson{} = lesson) do
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
