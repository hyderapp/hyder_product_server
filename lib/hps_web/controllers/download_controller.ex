defmodule HPSWeb.DownloadController do
  @moduledoc false

  use HPSWeb, :controller

  def show(conn, %{"package" => [path]}) do
    file = zip_path(path)

    if File.exists?(file) do
      send_file(conn, 200, zip_path(path))
    else
      conn
      |> put_status(:not_found)
      |> text("not found")
    end
  end

  defp zip_path(file),
    do: Path.join([:code.priv_dir(:hps), "archive", file])
end
