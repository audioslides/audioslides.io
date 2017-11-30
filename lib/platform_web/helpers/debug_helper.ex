defmodule PlatformWeb.DebugHelper do
  @moduledoc false
  use Phoenix.HTML

  @doc """
  iex> debug(%{test: "yes"}) |> safe_to_string()
  ~s(<pre><code>%{test: &quot;yes&quot;}</code></pre>)

  iex> debug(nil) |> safe_to_string()
  ~s(<pre><code>nil</code></pre>)
  """
  def debug(input, opts \\ []) do
    content_tag :pre, opts do
      content_tag :code do
        inspect(input, pretty: true, limit: 1000, width: 150)
      end
    end
  end
end
