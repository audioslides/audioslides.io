defmodule Platform.VideoProcessingState do
  @moduledoc """
  Context for the video converter
  """

  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide
  alias Platform.Video

  def get_processing_state(%Lesson{slides: slides} = lesson) when is_list(slides) do
    %{
     lesson_id: lesson.id,
     video_state: get_state_for_lesson_video(lesson),
     slides: Enum.map(slides, fn slide -> get_processing_state_for_slide(slide) end)
    }
  end
  def get_processing_state(%Lesson{slides: slides} = lesson) when not is_list(slides) do
    %{
     lesson_id: lesson.id,
     video_state: get_state_for_lesson_video(lesson),
     slides: []
    }
  end

  def get_state_for_lesson_video(%Lesson{video_hash: nil}), do: "NEW"
  def get_state_for_lesson_video(%Lesson{video_hash: video_hash} = lesson) do
    case Video.generate_video_hash(lesson) == video_hash do
      true -> "NO_UPDATED_NEEDED"
      false -> "NEED_UPDATE"
    end
  end

  def get_processing_state_for_slide(%Slide{} = slide) do
    %{
      slide_id: slide.id,
      video_state: get_state_for_slide_video(slide),
      audio_state: get_state_for_slide_audio(slide),
      image_state: get_state_for_slide_image(slide)
    }
  end

  def get_state_for_slide_audio(%Slide{audio_hash: nil}), do: "NEW"
  def get_state_for_slide_audio(%Slide{audio_hash: audio_hash, speaker_notes_hash: speaker_notes_hash}) do
    case speaker_notes_hash == audio_hash do
      true -> "NO_UPDATED_NEEDED"
      false -> "NEED_UPDATE"
    end
  end

  def get_state_for_slide_image(%Slide{image_hash: nil}), do: "NEW"
  def get_state_for_slide_image(%Slide{image_hash: image_hash, page_elements_hash: page_elements_hash}) do
    case page_elements_hash == image_hash do
      true -> "NO_UPDATED_NEEDED"
      false -> "NEED_UPDATE"
    end
  end

  def get_state_for_slide_video(%Slide{video_hash: nil}), do: "NEW"
  def get_state_for_slide_video(%Slide{video_hash: video_hash} = slide) do
    case Video.generate_video_hash(slide) == video_hash do
      true -> "NO_UPDATED_NEEDED"
      false -> "NEED_UPDATE"
    end
  end

end
