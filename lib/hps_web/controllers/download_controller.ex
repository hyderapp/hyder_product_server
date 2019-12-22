defmodule HPSWeb.DownloadController do
  @moduledoc false

  use HPSWeb, :controller

  def show(conn, %{"package" => [path]}) do
    file = zip_path(path)

    if File.exists?(file) do
      send_download(conn, {:file, file})
    else
      conn
      |> put_status(:not_found)
      |> text("not found")
    end
  end

  defp zip_path(file), do: Path.join(storage_path(), file)

  defp storage_path(),
    do:
      Application.get_env(
        :hps,
        :archive_storage_path,
        Path.join([:code.priv_dir(:hps), "archive"])
      )
end
