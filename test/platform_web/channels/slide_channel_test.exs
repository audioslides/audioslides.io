defmodule PlatformWeb.SlideChannelTest do
  @moduledoc """
  Test for the speechChannel for socket communitcation in the context of a slide
  """
  use PlatformWeb.ChannelCase

  alias PlatformWeb.SlideChannel

  setup do
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(SlideChannel, "slide")

    {:ok, socket: socket}
  end

  describe "speech" do
    test "should return a preview_url", %{socket: socket} do
      push socket, "speech", %{"some" => "payload"}
      assert_broadcast "speech", %{"preview_url" => "http://mocked-amazon.com/polly/?Text=EXAMPLE"}
    end
  end


end
