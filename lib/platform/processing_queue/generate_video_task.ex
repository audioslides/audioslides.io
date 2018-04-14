defmodule Platform.ProcessingQueue.GenerateVideoTask do
  @moduledoc """
  Task for processing the generation of videos
  """
  require Logger

  use Honeydew.Progress

  alias Platform.Core
  alias Platform.VideoProcessing
  alias PlatformWeb.LessonChannel

  @behaviour Honeydew.Worker

  def generate_video(lesson) do
    Logger.info "I started to generate a video for lesson #{lesson.id}!"

    # Enum.with_index(lesson.slides), fn {slide, index}
    Enum.each lesson.slides, fn slide ->
      VideoProcessing.generate_video_for_slide(lesson, slide)
      progress("Video #{slide.id} done!")
      broadcast_processing_update(lesson.id)
    end

    VideoProcessing.merge_videos(lesson)

    Logger.info "I finished the video for lesson #{lesson.id}!"
  end

  def broadcast_processing_update(id) do
    lesson = Core.get_lesson_with_slides!(id)
    LessonChannel.broadcast_processing_to_socket(lesson)

    lesson
  end
end
