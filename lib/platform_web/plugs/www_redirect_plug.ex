defmodule PlatformWeb.WwwRedirectPlug do
  @moduledoc """
  Removes the www. from an url
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if String.starts_with?(conn.host, "www.") do
      redirect_to_naked_domain(conn)
    else
      conn
    end
  end

  defp redirect_to_naked_domain(conn) do
    status = if conn.method in ~w(HEAD GET), do: 301, else: 307

    location = "https://" <> naked_host(conn.host) <> conn.request_path <> qs(conn.query_string)

    conn
    |> put_resp_header("location", location)
    |> send_resp(status, "You are being redirected")
    |> halt()
  end

  defp naked_host(host), do: String.trim_leading(host, "www.")

  defp qs(""), do: ""
  defp qs(qs), do: "?" <> qs
end
