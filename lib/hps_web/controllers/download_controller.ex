defmodule HPSWeb.DownloadController do
  @moduledoc false

  use HPSWeb, :controller

  def show(conn, %{"package" => [path]}) do
    send_file(conn, 200, zip_path(path))
  end

  defp zip_path(file),
    do: Path.join([:code.priv_dir(:hps), "archive", file])
end
