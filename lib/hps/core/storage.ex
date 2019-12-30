defmodule HPS.Core.Storage do
  @moduledoc """
  Storage provides a machnism for saving and reading files and package archives.
  """

  alias HPS.Core.Package

  @doc """
  Persist archive of a package.
  """
  @spec save_archive(Package.t()) :: :ok | {:error, term}
  def save_archive(package) do
    apply(engine(), :save_archive, [package])
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

  def archive_download_url(namespace, product_name, version) do
    apply(engine(), :archive_download_url, [namespace, product_name, version])
  end

  defp engine, do: Application.get_env(:hps, :storage, __MODULE__.Local)

  defmodule Local do
    @moduledoc """
    Default storage engine with ability of interacting with local file system.
    """
    require Logger
    alias HPSWeb.Router.Helpers, as: Routes

    def save_archive(%{archive: archive} = package) do
      path = archive_path(package)

      Logger.info("write archive to #{path}")

      with :ok <- File.mkdir_p(Path.dirname(path)),
           :ok <- File.write(path, archive) do
        :ok
      end
    end

    def locate_archive(package) do
      %{product: %{namespace: ns, name: name}, version: version} = package
      {:file, Path.join([archive_storage_dir(), ns, name, "#{version}.zip"])}
    end

    defp archive_path(%{product: %{name: name, namespace: ns}, version: version}) do
      Path.join([archive_storage_dir(), ns, name, "#{version}.zip"])
    end

    defp archive_storage_dir() do
      Application.get_env(
        :hps,
        :archive_storage_path,
        Path.join([:code.priv_dir(:hps), "archive"])
      )
    end

    def archive_download_url("default", product, version),
      do:
        Routes.download_url(HPSWeb.Endpoint, :show, [
          product_package_name(product, version)
        ])

    def archive_download_url(ns, product, version),
      do:
        Routes.download_url(
          HPSWeb.Endpoint,
          :show,
          [product_package_name(product, version)],
          namespace: ns
        )

    defp product_package_name(product, version) do
      "#{product}-#{version}.zip"
    end
  end
end
