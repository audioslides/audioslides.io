defmodule Platform.ProcessingQueue.HeavyTask do
  use Honeydew.Progress

  alias Platform.VideoProcessing

  @behaviour Honeydew.Worker

  def work_really_hard(lesson) do
    IO.puts "I started really hard work!"

    Enum.each lesson.slides, fn slide ->
      VideoProcessing.generate_video_for_slide(lesson, slide)
      progress("Video #{slide.id} done!")
    end

    VideoProcessing.merge_videos(lesson)

    IO.puts "My Work is done"
  end
end
