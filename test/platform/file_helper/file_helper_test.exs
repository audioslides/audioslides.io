defmodule Platform.FileHelperTest do
  use ExUnit.Case, async: false
  import Mock
  import Platform.FileHelper.FileSystemAdapter

  setup_with_mocks([
    {File, [], [
      rm: fn _ -> true end,
      close: fn _ -> true end,
      open: fn _out, _opts -> {:ok, nil} end,
      mkdir_p: fn _ -> true end
      ]},
    {IO, [:passthrough], [binwrite: fn _file, _content -> true end]}
    ])
  do
    {:ok, filename: "/example/dir/filename.ext", data: "exampleData"}
  end

  describe "the write_to_file function" do
    test "should create the directory for the file", %{filename: filename, data: data} do
      write_to_file(filename, data)

      assert called File.mkdir_p("/example/dir/")
    end
    test "should write the content to the file", %{filename: filename, data: data} do
      write_to_file(filename, data)

      assert called File.open(filename, [:write])
      assert called IO.binwrite(:_, data)
      assert called File.close(:_)
    end
  end
end
