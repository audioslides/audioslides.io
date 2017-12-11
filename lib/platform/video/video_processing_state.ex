defmodule Platform.VideoProcessingState do
  @moduledoc """
  Context for the video converter
  """

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide
  alias Platform.VideoHelper

  def set_processing_state(%Lesson{} = lesson) do
    processing_state = get_processing_state(lesson)

    processing_state.slides
    |> Enum.each(fn(state) ->
      set_video_processing_state(state)
      set_audio_processing_state(state)
      set_image_processing_state(state)
    end)


    Core.update_lesson(lesson, %{video_sync_pid: "self()"})

    lesson
  end

  def set_video_processing_state(%{video_state: "NEEDS_UPDATE", slide_id: id} = state) do
    slide = Core.get_slide!(id)

    Core.update_slide(slide, %{video_sync_pid: "self()"})

    state
  end
  def set_video_processing_state(state), do: state

  def set_audio_processing_state(%{audio_state: "NEEDS_UPDATE", slide_id: id} = state) do
    slide = Core.get_slide!(id)

    Core.update_slide(slide, %{audio_sync_pid: "self()"})

    state
  end
  def set_audio_processing_state(state), do: state

  def set_image_processing_state(%{image_state: "NEEDS_UPDATE", slide_id: id} = state) do
    slide = Core.get_slide!(id)

    Core.update_slide(slide, %{image_sync_pid: "self()"})

    state
  end
  def set_image_processing_state(state), do: state

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

  def get_state_for_lesson_video(%Lesson{video_sync_pid: video_sync_pid}) when not is_nil(video_sync_pid), do: "UPDATING"
  def get_state_for_lesson_video(%Lesson{video_hash: nil}), do: "NEEDS_UPDATE"
  def get_state_for_lesson_video(%Lesson{video_hash: video_hash} = lesson) do
    case VideoHelper.generate_video_hash(lesson) == video_hash do
      true -> "UP_TO_DATE"
      false -> "NEEDS_UPDATE"
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

  def get_state_for_slide_audio(%Slide{audio_sync_pid: audio_sync_pid}) when not is_nil(audio_sync_pid), do: "UPDATING"
  def get_state_for_slide_audio(%Slide{audio_hash: nil}), do: "NEEDS_UPDATE"
  def get_state_for_slide_audio(%Slide{audio_hash: audio_hash, speaker_notes_hash: speaker_notes_hash}) do
    case speaker_notes_hash == audio_hash do
      true -> "UP_TO_DATE"
      false -> "NEEDS_UPDATE"
    end
  end

  def get_state_for_slide_image(%Slide{image_sync_pid: image_sync_pid}) when not is_nil(image_sync_pid), do: "UPDATING"
  def get_state_for_slide_image(%Slide{image_hash: nil}), do: "NEEDS_UPDATE"
  def get_state_for_slide_image(%Slide{image_hash: image_hash, page_elements_hash: page_elements_hash}) do
    case page_elements_hash == image_hash do
      true -> "UP_TO_DATE"
      false -> "NEEDS_UPDATE"
    end
  end

  def get_state_for_slide_video(%Slide{video_sync_pid: video_sync_pid}) when not is_nil(video_sync_pid), do: "UPDATING"
  def get_state_for_slide_video(%Slide{video_hash: nil}), do: "NEEDS_UPDATE"
  def get_state_for_slide_video(%Slide{video_hash: video_hash} = slide) do
    case VideoHelper.generate_video_hash(slide) == video_hash do
      true -> "UP_TO_DATE"
      false -> "NEEDS_UPDATE"
    end
  end

end
