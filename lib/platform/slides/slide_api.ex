defmodule Platform.SlideAPI do
  @moduledoc """
  Context for the general converter
  """

  @doc """
  Get a presentation from the api

  """
  @callback get_presentation(String.t()) :: {:ok, String.t()} | {:error, String.t()}

  @doc """
  Get a slide from the api

  """
  @callback get_slide!(String.t(), String.t()) :: {}

  @doc """
  Get a slide from the api

  """
  @callback get_slide!(String.t(), String.t()) :: {}

  @doc """
  Get a slide thump from the api

  """
  @callback get_slide_thumb!(String.t(), String.t()) :: {}

  @doc """
  Get a download a slide thump from the api

  """
  @callback download_slide_thumb!(String.t(), String.t(), String.t()) :: {}
end
