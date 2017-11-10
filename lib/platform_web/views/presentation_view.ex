defmodule PlatformWeb.PresentationView do
  use PlatformWeb, :view

  @content_dir Application.get_env(:platform, :content_dir)

  def get_lang_icon("de-DE"), do: "🇩🇪"
  def get_lang_icon("en-US"), do: "🇺🇸"
  def get_lang_icon(lang), do: lang

  def get_gender_icon("male"), do: "👨‍🏫"
  def get_gender_icon("female"), do: "👩‍🏫"
  def get_gender_icon(gender), do: gender

  def get_frontimage(%{slides: slides} = presentation) when length(slides) > 0 do
      slide_id = List.first(presentation.slides).id
      if File.exists?("#{@content_dir}#{presentation.id}/#{slide_id}.png") do
        "/content/#{presentation.id}/#{slide_id}.png"
      else
        "/images/example-slide.png"
      end
  end
  def get_frontimage(_), do: "/images/example-slide.png"

  def get_slide_image(presentation, slide) do
    if File.exists?("#{@content_dir}#{presentation.id}/#{slide.id}.png") do
      "/content/#{presentation.id}/#{slide.id}.png"
    else
      "/images/example-slide.png"
    end
end

end
