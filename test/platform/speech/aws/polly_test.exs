defmodule Platform.Speech.AWS.PollyTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import Platform.Speech.AWS.Polly

  doctest Platform.Speech.AWS.Polly

  describe "get_speech" do
    test "should convert text to speech" do
      use_cassette "polly#working" do
        params = %{
          "language_key" => "de-DE",
          "voice_gender" => "male",
          "text" => "TEST"
        }

        response = get_speech(params)

        # MP3 Header
        assert response =~ <<73, 68, 51, 4, 0, 0, 0, 0, 0>>
      end
    end

    test "should raise an error on wrong parameters" do
      use_cassette "polly#failing" do
        params = %{
          "language_key" => "de-DE",
          "voice_gender" => "male",
          "text" => "TEST"
        }

        assert_raise RuntimeError, ~r/^Error in AWS Speech Polly at HTTP: nxdomain$/, fn ->
          get_speech(params)
        end
      end
    end

    test "should raise error when service return a 404" do
      use_cassette "polly#failing404" do
        params = %{
          "language_key" => "de-DE",
          "voice_gender" => "male",
          "text" => "TEST"
        }

        assert_raise RuntimeError, ~r/^404 - Not found$/, fn ->
          get_speech(params)
        end
      end
    end
  end
end
