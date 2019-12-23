defmodule HPSWeb.DownloadController do
  @moduledoc false

  use HPSWeb, :controller

  require Logger

  def show(conn, %{"package" => [path]}) do
    file = zip_path(path)

    if File.exists?(file) do
      send_download(conn, {:file, file})
    else
      Logger.warn("package not found: #{file}")

      conn
      |> put_status(:not_found)
      |> text("not found")
    end
  end

  defp zip_path(file), do: Path.join(HPS.Core.archive_storage_dir(), file)
end
