defmodule HPSWeb.HealthController do
  @moduledoc """
  This controller is for health checking.
  """

  use HPSWeb, :controller

  def show(conn, _params) do
    text(conn, "OK")
  end
end
