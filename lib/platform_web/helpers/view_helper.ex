defmodule PlatformWeb.ViewHelper do
  @moduledoc false

  @example_image "/images/example-slide.png"

  @doc """
  iex> lang_icon("de-DE")
  ~s(🇩🇪)

  iex> lang_icon("en-US")
  ~s(🇺🇸)

  iex> lang_icon("pl-pl")
  ~s(pl-pl)
  """
  def lang_icon("de-DE"), do: "🇩🇪"
  def lang_icon("en-US"), do: "🇺🇸"
  def lang_icon(lang), do: lang

  @doc """
  iex> voice_gender_icon("male")
  ~s(👨‍🏫)

  iex> voice_gender_icon("female")
  ~s(👩‍🏫)

  iex> voice_gender_icon("non-binary")
  ~s(Not supported)
  """
  def voice_gender_icon("male"), do: "👨‍🏫"
  def voice_gender_icon("female"), do: "👩‍🏫"
  def voice_gender_icon(_), do: "Not supported"

  @doc """
  Get the image for the first slide of a lesson.
  If no image is available use the example image.

  iex> get_course_front_slide_image(%{id: 1, slides: [%{id: 2, image_hash: "A"}]})
  "/content/1/2.png"

  iex> get_course_front_slide_image(%{id: 1, slides: [%{id: 2, image_hash: "A"}, %{id: 3, image_hash: "A"}]})
  "/content/1/2.png"

  iex> get_course_front_slide_image(%{id: 5, slides: [%{id: 100, image_hash: "B"}]})
  "/content/5/100.png"

  iex> get_course_front_slide_image(%{id: 5})
  "/images/example-slide.png"

  """
  def get_course_front_slide_image(%{slides: slides} = lesson) when length(slides) > 0 do
    slide = List.first(lesson.slides)
    get_slide_image(lesson, slide)
  end

  def get_course_front_slide_image(_), do: @example_image

  @doc """
  Get the image for the a slide.
  If no image is available use the example image.

  iex> get_slide_image(%{id: 5}, %{id: 100, image_hash: "B"})
  "/content/5/100.png"

  iex> get_slide_image(%{id: 5}, %{id: 100})
  "/images/example-slide.png"

  """
  def get_slide_image(
        %{id: lesson_id} = _lesson,
        %{image_hash: image_hash, id: slide_id} = _slide
      )
      when is_binary(image_hash) do
    "/content/#{lesson_id}/#{slide_id}.png"
  end

  def get_slide_image(_lesson, _slide), do: @example_image
end
