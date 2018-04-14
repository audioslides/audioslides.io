defmodule Platform.ProcessingQueue.HeavyTask do
  require Logger

  use Honeydew.Progress

  alias Platform.VideoProcessing

  @behaviour Honeydew.Worker

  def generate_video(lesson) do
    Logger.info "I started to generate a video for lesson #{lesson.id}!"

    # Enum.with_index(lesson.slides), fn {slide, index}
    Enum.each lesson.slides, fn slide ->
      VideoProcessing.generate_video_for_slide(lesson, slide)
      progress("Video #{slide.id} done!")
    end

    VideoProcessing.merge_videos(lesson)

    Logger.info "I finished the video for lesson #{lesson.id}!"
  end
end