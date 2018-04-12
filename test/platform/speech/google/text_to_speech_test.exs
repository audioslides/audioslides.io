defmodule Platform.Speech.Google.TextToSpeechTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import Platform.Speech.Google.TextToSpeech

  doctest Platform.Speech.Google.TextToSpeech

  describe "get_speech" do
    test "should convert text to speech" do
      use_cassette "google_tts#valid" do
        params = %{
          "language_key" => "en-US",
          "voice_gender" => "male",
          "text" => "TEST"
        }
        response = get_speech(params)

        # MP3 Header
        assert response =~ <<255, 243, 68, 196, 0, 0, 0, 3, 72>>
      end
    end
  end
end
