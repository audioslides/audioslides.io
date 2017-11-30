defmodule Platform.SpeechAPI do
  @moduledoc """
  The Speech context
  """

  @callback get_speech(params :: Map.t()) :: any
end
