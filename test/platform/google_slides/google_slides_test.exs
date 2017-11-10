defmodule Platform.GoogleSlidesTest do
  use ExUnit.Case

  alias GoogleApi.Slides.V1.Model.Page
  alias GoogleApi.Slides.V1.Model.PageElement

  import Platform.GoogleSlidesFactory
  import Platform.GoogleSlides

  doctest Platform.GoogleSlides

end
