defmodule Platform.GoogleSlidesHelperTest do
  @moduledoc """
  Test GoogleSlideHelper functions and mock external API
  """
  use ExUnit.Case

  alias GoogleApi.Slides.V1.Model.Page
  alias GoogleApi.Slides.V1.Model.PageElement

  import Platform.GoogleSlidesFactory
  import Platform.GoogleSlidesHelper

  doctest Platform.GoogleSlidesHelper
end
