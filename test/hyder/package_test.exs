defmodule HyderPackageTest do
  use ExUnit.Case

  alias Hyder.Package

  import Hyder.Package
  import Hyder.Util.Zip
  import Hyder.Util.Digest

  doctest Package

  describe "add_files_from_archive/2" do
    test "it works" do
      zip = "test/fixtures/shop-v1.0.0-df8d87ef.zip"

      package =
        Package.new("test")
        |> add_files_from_archive({:file, zip})

      assert %Hyder.Package{} = package

      file = hd(package.files)
      digest = "sjwcqfjnc7h3ulzhk7w2cxpq5yo7xqsroxk7lgwjqsw3tric6kgq"

      assert %{digest: ^digest, path: "stuff/shop/index.html", size: 1295} = file
    end
  end

  describe "build_full_distribution/1" do
    test "it works" do
      package =
        Package.new(
          "1.0.0",
          files: [
            file("dist/index.html", "hello world"),
            file("dist/a/test.txt", "foo bar fooo baar")
          ]
        )

      {:ok, content} = build_full_distribution(package)

      assert zip_entries(content) == package.files
    end
  end

  describe "build_update_distribution/2" do
    test "it works" do
      base =
        Package.new(
          "0.1.0",
          files: [
            file("dist/a/test.txt", "foo bar fooo baar")
          ]
        )

      package =
        Package.new(
          "1.0.0",
          files: [
            file("dist/index.html", "hello world"),
            file("dist/a/test.txt", "foo bar fooo baar")
          ]
        )

      {:ok, content} = build_update_distribution(package, base)

      assert zip_entries(content) == [file("dist/index.html", "hello world")]
    end
  end

  defp file(path, content) do
    %Hyder.File{path: path, content: content, digest: hash(content), size: byte_size(content)}
  end
end
