defmodule HPS.Core.Storage do
  @moduledoc """
  Storage provides a machnism for saving and reading files and package archives.
  """

  alias HPS.Core.Package

  def save_archive(package) do
    apply(engine(), :save_archive, [package])
  end

  defp engine do
    __MODULE__.Local
  end

  @doc """
  Given the package info, returns the archive storage location. The result should
  be in either of the formats below:

  - `{:file, local_file_path}`
  - `{:url, remote_file_url}`
  """
  @spec locate_archive(Package.t()) ::
          {:file, binary} | {:url, binary} | {:error, term}
  def locate_archive(package) do
    apply(engine(), :locate_archive, [package])
  end

  defmodule Local do
    @moduledoc """
    Default storage engine with ability of interacting with local file system.
    """
    require Logger

    def save_archive(%{archive: archive, product: product, version: version} = package) do
      path = archive_path(product, version)

      Logger.info("write archive to #{path}")

      with :ok <- File.mkdir_p(Path.dirname(path)),
           :ok <- File.write(path, archive) do
        :ok
      end
    end

    defp archive_path(%{name: name, namespace: ns} = product, version) do
      Path.join([archive_storage_dir(), ns, name, zip_file_name(version)])
    end

    defp archive_storage_dir() do
      Application.get_env(
        :hps,
        :archive_storage_path,
        Path.join([:code.priv_dir(:hps), "archive"])
      )
    end

    defp zip_file_name(version) do
      "#{version}.zip"
    end

    def locate_archive(package) do
      %{product: %{namespace: ns, name: name}, version: version} = package
      {:file, Path.join([archive_storage_dir(), ns, name, zip_file_name(version)])}
    end
  end
end
