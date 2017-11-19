defmodule Platform.FileHelper do
  @moduledoc """
  Context for the general converter
  """
  @adapter Application.get_env(:platform, __MODULE__, [])[:adapter]

  @doc """
  Write a file via the File Module

  """
  @callback write_to_file(filename: String.t, data: String.t) :: {:ok, String.t} | {:error, String.t}
  defdelegate write_to_file(filename, data), to: @adapter

end
