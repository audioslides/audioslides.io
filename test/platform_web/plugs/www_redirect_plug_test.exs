defmodule PlatformWeb.WwwRedirectPlugTest do
  alias PlatformWeb.WwwRedirectPlug
  use PlatformWeb.ConnCase

  describe "#init" do
    test "passes the options unmodified" do
      opts = %{test: 123}
      assert WwwRedirectPlug.init(opts) == opts
    end
  end

  describe "#call" do
    test "redirects does nothing if there's no www at the beginning" do
      conn = %{build_conn(:get, "/") | host: "workshops.de"}
      response = WwwRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) ==
               {"cache-control", "max-age=0, private, must-revalidate"}
    end

    test "test redirect of naked path" do
      conn = %{build_conn(:get, "/") | host: "www.workshops.de"}
      response = WwwRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/"}
      assert response(response, 301)
    end

    test "test redirect of path" do
      conn = %{build_conn(:get, "/some/path") | host: "www.workshops.de"}
      response = WwwRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/some/path"}
      assert response(response, 301)
    end

    test "test redirect of path with params" do
      conn = %{build_conn(:get, "/some/path?foo=bar") | host: "www.workshops.de"}
      response = WwwRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) ==
               {"location", "https://workshops.de/some/path?foo=bar"}

      assert response(response, 301)
    end

    test "test redirect with ssl" do
      conn = %{build_conn(:get, "/some/path") | host: "www.workshops.de"}
      response = WwwRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/some/path"}
      assert response(response, 301)
    end
  end
end
