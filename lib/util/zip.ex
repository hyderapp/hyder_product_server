defmodule Hyder.Util.Zip do
  @moduledoc """
  Zip file related utils functions.
  """

  import Hyder.Util.Digest, only: [hash: 1]

  @ignore_file_patten ~r/\.DS_Store$/

  @doc """
  Get file entries in a zip archive, the result will appear in hyder file structs.
  """
  def zip_entries(archive_io) do
    {:ok, extract} =
      archive_io
      |> to_erl_open_term()
      |> :zip.extract([:memory])

    to_files(extract)
  end

  defp to_erl_open_term({:file, file}) when is_binary(file), do: String.to_charlist(file)

  defp to_erl_open_term(content) when is_binary(content), do: content

  defp to_files(extract) do
    extract
    |> Stream.map(fn {name, bin} -> {to_string(name), bin} end)
    |> Stream.reject(&ignore?/1)
    |> Stream.map(&to_hyder_file_struct/1)
    |> Enum.to_list()
  end

  defp ignore?({name, _}) do
    Regex.match?(@ignore_file_patten, name)
  end

  defp to_hyder_file_struct({name, bin}) do
    %{
      path: to_string(name),
      digest: hash(bin),
      size: byte_size(bin),
      content: bin
    }
  end

  @doc """
  Create a zip archive in memory with a list of hyder files provided.
  """
  def create(files) do
    files = Enum.map(files, &to_erl_file_struct/1)
    {:ok, {_, content}} = :zip.create('out', files, [:memory])
    {:ok, content}
  end

  defp to_erl_file_struct(%{path: path, content: content}) do
    {String.to_charlist(path), content}
  end
end
