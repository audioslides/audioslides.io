defmodule Platform.ConverterTest do
  use ExUnit.Case
  import Platform.Converter
  import Mock

  import Platform.Speech.Mock.System


  doctest Platform.Converter

  test "get_audio_duration" do
    with_mock System, [cmd: &cmd(&1, &2, &3)] do
      result = get_audio_duration("test/support/fixtures/slide.mp3")
      assert result == "00:09.59"
    end
  end
end
