defmodule HPSWeb.DownloadController do
  @moduledoc false

  use HPSWeb, :controller

  require Logger

  def show(conn, %{"package" => [path]}) do
    [name, version] =
      path
      |> String.trim_trailing(".zip")
      |> String.split("-", parts: 2)

    product = %{name: name, namespace: conn.assigns.namespace}
    package = %{product: product, version: version}

    HPS.Core.Storage.locate_archive(package)
    |> case do
      {:file, file} ->
        send_file(conn, file)

      {:url, url} ->
        redirect(conn, external: url)
    end
  end

  defp send_file(conn, path) do
    if File.exists?(path) do
      send_download(conn, {:file, path})
    else
      Logger.warn("package not found: #{path}")

      conn
      |> put_status(:not_found)
      |> text("not found")
    end
  end
end
