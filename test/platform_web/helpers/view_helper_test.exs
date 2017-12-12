defmodule PlatformWeb.ViewHelperTest do
  use ExUnit.Case
  import PlatformWeb.ViewHelper

  alias Platform.Core.Schema.Course

  doctest PlatformWeb.ViewHelper

  describe "#get_overall_duration" do
    test "should sum up all durations of all lessons" do
      course = %Course{
        course_lessons: [
          %{lesson: %{duration: 100}},
          %{lesson: %{duration: 1}}
        ]
      }
      duration_sum = get_overall_duration(course)

      assert duration_sum == 101
    end
  end
end
