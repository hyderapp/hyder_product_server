defmodule HPSWeb.Admin.RolloutController do
  @moduledoc false

  use HPSWeb, :controller

  alias HPS.Core
  alias HPS.Core.Rollout

  plug(HPSWeb.RequireProduct)

  action_fallback(HPSWeb.JsonFallbackController)

  def index(conn, _params) do
    rollouts = Core.list_rollouts(conn.assigns.product)

    conn
    |> render("index.json", rollouts: rollouts)
  end

  def create(conn, params) do
    product = conn.assigns.product

    with {:ok, version} <- version(params),
         {:ok, package} <- Core.get_package_by_version(product, version),
         {:ok, %Rollout{} = rollout} <- Core.create_rollout(product, package) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.product_rollout_path(conn, :show, product.name, rollout)
      )
      |> render("show.json", rollout: rollout)
    end
  end

  def show(conn, %{"id" => id}) do
    rollout = Core.get_rollout_by_version(conn.assigns.product, id)
    render(conn, "show.json", rollout: rollout)
  end

  def update(conn, %{"id" => id} = params) do
    with %Rollout{} = rollout <- Core.get_rollout_by_version(conn.assigns.product, id),
         {:ok, %Rollout{} = rollout} <- Core.update_rollout(rollout, params) do
      render(conn, "show.json", rollout: rollout)
    end
  end

  def delete(conn, %{"id" => id}) do
    rollout = Core.get_rollout!(id)

    with {:ok, %Rollout{}} <- Core.delete_rollout(rollout) do
      send_resp(conn, :no_content, "")
    end
  end

  defp version(%{"version" => v}) when is_binary(v), do: {:ok, v}
  defp version(_), do: {:error, :not_found}
end
