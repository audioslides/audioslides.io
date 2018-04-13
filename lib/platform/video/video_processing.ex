defmodule Platform.VideoProcessing do
  @moduledoc """
  Context for the video converter
  """
  require Logger

  alias Platform.Filename
  alias Platform.FileHelper
  alias Platform.Speech
  alias Platform.VideoConverter
  alias Platform.VideoHelper

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  def convert_lesson_to_video(%Lesson{} = lesson) do
    Task.async_stream(lesson.slides, fn(slide) -> generate_video_for_slide(lesson, slide) end, timeout: 120_000)
  end

  def merge_videos(lesson) do
    Logger.info("Videos for Lesson ##{lesson.id} will be merged ...")
    generated_video_filenames = Enum.map(lesson.slides, fn slide -> Filename.get_relative_filename_for_slide_video(lesson, slide) end)
    final_output_filename = Filename.get_filename_for_lesson_video(lesson)

    VideoConverter.merge_videos(
      video_filename_list: generated_video_filenames,
      output_filename: final_output_filename
    )

    duration_in_seconds =
      final_output_filename
      |> VideoConverter.get_duration()
      |> parse_duration()

    Core.update_lesson(lesson, %{duration: duration_in_seconds, video_hash: VideoHelper.generate_video_hash(lesson)})

    Logger.info("Lesson ##{lesson.id} merge complete")
  end

  def parse_duration(<<minutes_as_string::bytes-size(2)>> <> ":" <> <<seconds_as_string::bytes-size(2)>> <> "." <> miliseconds_as_string), do: parse_duration("00:#{minutes_as_string}:#{seconds_as_string}.#{miliseconds_as_string}")
  def parse_duration(<<hours_as_string::bytes-size(2)>> <> ":" <> <<minutes_as_string::bytes-size(2)>> <> ":" <> <<seconds_as_string::bytes-size(2)>> <> "." <> _miliseconds_as_string) do
    hours = String.to_integer(hours_as_string)
    minutes = String.to_integer(minutes_as_string)
    seconds = String.to_integer(seconds_as_string)
    seconds + (minutes * 60) + (hours * 3600)
  end
  def parse_duration(_), do: 0

  def generate_video_for_slide(%Lesson{} = lesson, %Slide{} = slide) do
    # Only generate video of audio or video changed
    #if VideoHelper.generate_video_hash(slide) != slide.video_hash do
      Logger.info("Slide #{slide.id} Video: need update")

      image_filename = create_or_update_image_for_slide(lesson, slide)
      audio_filename = create_or_update_audio_for_slide(lesson, slide)
      video_filename = Filename.get_filename_for_slide_video(lesson, slide)

      Core.update_slide(slide, %{video_sync_pid: self()})

      VideoConverter.generate_video(
        image_filename: image_filename,
        audio_filename: audio_filename,
        output_filename: video_filename
      )

      Core.update_slide_video_hash(slide, VideoHelper.generate_video_hash(slide))
      Core.update_slide(slide, %{video_sync_pid: nil})

      Logger.info("Slide #{slide.id} Video: generated")
    #else
    #  Logger.info("Slide #{slide.id} Video: skipped")
    #end
  end

  def create_or_update_image_for_slide(lesson, slide) do
    if slide.page_elements_hash != slide.image_hash do
      Logger.info("Slide #{slide.id} Image: need update")

      Core.update_slide(slide, %{image_sync_pid: self()})

      Core.download_thumb!(lesson, slide)
      Core.update_slide_image_hash(slide, slide.page_elements_hash)

      Core.update_slide(slide, %{image_sync_pid: nil})

      Logger.info("Slide #{slide.id} Image: generated")
    else
      Logger.info("Slide #{slide.id} Image: skipped")
    end

    Filename.get_filename_for_slide_image(lesson, slide)
  end

  def create_or_update_audio_for_slide(lesson, slide) do
    audio_filename = Filename.get_filename_for_slide_audio(lesson, slide)

    if slide.speaker_notes_hash != slide.audio_hash do
      Logger.info("Slide #{slide.id} Audio: need update")

      Core.update_slide(slide, %{audio_sync_pid: self()})

      speech_binary =
        Speech.run(%{
          "language_key" => lesson.voice_language,
          "voice_gender" => lesson.voice_gender,
          "text" => slide.speaker_notes
        })

      FileHelper.write_to_file(audio_filename, speech_binary)
      Core.update_slide_audio_hash(slide, slide.speaker_notes_hash)

      Core.update_slide(slide, %{audio_sync_pid: nil})

      Logger.info("Slide #{slide.id} Audio: generated")
    else
      Logger.info("Slide #{slide.id} Audio: skipped")
    end

    audio_filename
  end

end
