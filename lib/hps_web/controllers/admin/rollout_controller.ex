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

  def show(conn, %{"target_version" => target_version}) do
    rollout = Core.get_rollout_by_version(conn.assigns.product, target_version)
    render(conn, "show.json", rollout: rollout)
  end

  def show_current(conn, _params) do
    rollout = Core.current_rollout(conn.assigns.product)
    render(conn, "show.json", rollout: rollout)
  end

  def update(conn, %{"target_version" => target_version} = params) do
    with %Rollout{} = rollout <-
           Core.get_rollout_by_version(conn.assigns.product, target_version),
         {:ok, %Rollout{} = rollout} <- Core.update_rollout(rollout, params) do
      render(conn, "show.json", rollout: rollout)
    end
  end

  def delete(conn, _params) do
    json(conn, %{
      success: false,
      apiMessage: "this api is not implemented yet and always return failure."
    })
  end

  @doc """
  DELETE /products/{name}/rollout

  Rollback current rollout.
  """
  def rollback_current(conn, _params) do
    with {:rollout, %Rollout{} = rollout} <-
           {:rollout, Core.current_rollout(conn.assigns.product)},
         {:ok, _} <- Core.rollback(rollout) do
      json(conn, %{success: true})
    else
      {:rollout, nil} ->
        {:error, :not_found}
    end
  end

  defp version(%{"version" => v}) when is_binary(v), do: {:ok, v}
  defp version(_), do: {:error, :not_found}
end
