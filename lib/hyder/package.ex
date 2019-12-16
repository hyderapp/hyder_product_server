defmodule Hyder.Package do
  @moduledoc """
  A Hyder package represents a specifical version of the product.
  """

  alias Hyder.Util.Zip

  @type t() :: __MODULE__
  @type version() :: binary
  @type file() :: binary() | {:file, Path.t()}

  defstruct version: nil, files: []

  @doc """
  Build a new package struct.

  ## Example

      iex> Hyder.Package.new("1.10.5-seqzxbz")
      %Hyder.Package{version: "1.10.5-seqzxbz"}
  """
  @spec new(version()) :: t()
  def new(version, opts \\ []) do
    %__MODULE__{version: version}
    |> Map.merge(opts |> Enum.into(%{}))
  end

  @doc """
  Add a list of files to a package. The order of the files list is not guaranteed.

  ## Example

      iex> package = Hyder.Package.new("1.0.0")
      ...> add_files(package, [
      ...>   %{path: "/example/a.txt", digest: "0c3e94e", size: 578},
      ...>   %{path: "/example/b.txt", digest: "8d93c58", size: 1024}
      ...> ])
      %Hyder.Package{
        version: "1.0.0",
        files: [
          %{path: "/example/a.txt", digest: "0c3e94e", size: 578},
          %{path: "/example/b.txt", digest: "8d93c58", size: 1024}
        ]
      }
  """
  @spec add_files(t(), [file()]) :: t() | {:error, term()}
  def add_files(package, files) do
    set_files(package, &(&1 ++ files))
  end

  defp set_files(package, adder) do
    files = adder.(package.files) |> Enum.uniq_by(& &1.path)
    Map.put(package, :files, files)
  end

  @doc """
  Add a single file to a package. The order of the files list is not guaranteed.

  ## Example

      iex> package = Hyder.Package.new("1.0.0")
      ...> add_file(package, %{path: "/example/a.txt", digest: "0c3e94e", size: 578})
      %Hyder.Package{
        version: "1.0.0",
        files: [
          %{path: "/example/a.txt", digest: "0c3e94e", size: 578}
        ]
      }
  """
  @spec add_file(t(), file()) :: t() | {:error, term()}
  def add_file(package, file) do
    set_files(package, &[file | &1])
  end

  @doc """
  Add files from an compressed tar archive (.tar.gz).

  ## Example

      iex> package = Hyder.Package.new("1.0.0")
      ...> add_files_from_archive(package, {file: "path/to/zip"})

  The file should be compressed in `zip` format.
  """
  @spec add_file(t(), file()) :: t() | {:error, term()}
  def add_files_from_archive(package, archive_io) do
    add_files(package, Zip.zip_entries(archive_io))
  end

  @doc """
  Build a compressed package distribution, with all files in a single compressed
  tar ball.
  """
  @spec build_full_distribution(t()) :: {:ok, binary()}
  def build_full_distribution(%{files: files}) do
    Zip.create(files)
  end

  @doc """
  Build a compressed package distribution, with only updated and new files from
  the base version. Same files shared by both the versions will not apear in
  the updated distribution.
  """
  @spec build_update_distribution(t(), t()) :: {:ok, binary()}
  def build_update_distribution(package, base_package) do
    update = package.files -- base_package.files
    Zip.create(update)
  end
end
