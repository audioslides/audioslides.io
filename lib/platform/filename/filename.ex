defmodule Platform.Filename do
  @moduledoc """
  Context for all filenames for IO
  """
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  @content_dir Application.get_env(:platform, :content_dir)

  def get_filename_for_lesson_video(%Lesson{} = lesson) do
    "#{@content_dir}#{lesson.id}.mp4"
  end

  def get_filename_for_slide_video(%Lesson{} = lesson, %Slide{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.mp4"
  end

  def get_filename_for_slide_image(%Lesson{} = lesson, %Slide{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.png"
  end

  def get_filename_for_slide_audio(%Lesson{} = lesson, %Slide{} = slide) do
    "#{@content_dir}#{lesson.id}/#{slide.id}.mp3"
  end

  def get_directory_for_lesson(%Lesson{} = lesson) do
    "#{@content_dir}#{lesson.id}"
  end

  def get_filename_for_ffmpeg_concat(%Lesson{} = lesson) do
    "#{@content_dir}/ffmpeg_concat_temporary.txt"
  end


end
