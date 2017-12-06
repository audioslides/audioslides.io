defmodule PlatformWeb.LessonChannelTest do
  use PlatformWeb.ChannelCase

  alias Platform.Factory
  alias PlatformWeb.LessonChannel

  import PlatformWeb.LessonChannel

  setup do
    {:ok, _, socket} =
      socket
      |> subscribe_and_join(LessonChannel, "lesson:lobby")

    {:ok, socket: socket}
  end

  describe "join channel" do
    test "should assign lesson_id to the socket", %{socket: %{assigns: %{lesson_id: lesson_id}}} do
      assert lesson_id == "lobby"
    end
  end

  describe "#broadcast_processing_to_socket" do
    test "should broadcast" do
      lesson = Factory.insert(:lesson, name: "Lesson name")
      broadcast_processing_to_socket(lesson)

      #assert_broadcast "new-processing-state", %{}
    end
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push socket, "ping", %{"hello" => "there"}
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end

  # test "shout broadcasts to lesson:lobby", %{socket: socket} do
  #   push socket, "shout", %{"hello" => "all"}
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from! socket, "broadcast", %{"some" => "data"}
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
