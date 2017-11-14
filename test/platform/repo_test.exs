defmodule Platform.RepoTest do
  use Platform.DataCase

  describe "#touch_utc!" do
    test "sets the current time for an attribute" do
      course = Factory.insert(:course)
      {:ok, fake_now, 0} = DateTime.from_iso8601("2017-01-01T12:00:00Z")

      touched_course =
        course
        |> Repo.touch_utc!(:updated_at, fake_now)

      assert touched_course.updated_at == fake_now
    end
  end
end
