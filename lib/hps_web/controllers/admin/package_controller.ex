defmodule HPSWeb.Admin.PackageController do
  use HPSWeb, :controller

  alias HPS.Core
  alias HPS.Repo

  plug(HPSWeb.RequireProduct)

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    with packages <- Core.list_packages(conn.assigns.product) do
      conn
      |> render("index.json", packages: packages)
    end
  end

  def create(conn, params) do
    product = conn.assigns.product

    with {:ok, params} <- prepare_create(params, product),
         {:ok, package} <- Core.create_or_update_package(product, params) do
      conn
      |> put_status(:created)
      |> render("show.json", package: package)
    end
  end

  def show(conn, %{"version" => version}) do
    with {:ok, package} <- fetch_package(conn.assigns.product.id, version) do
      conn
      |> render("show-with-detail.json", package: package)
    end
  end

  def delete(conn, %{"version" => version}) do
    with {:ok, package} <- Core.get_package_by_version(conn.assigns.product.id, version),
         {:ok, _} <- Core.delete_package(package) do
      conn
      |> render("delete.json", [])
    else
      {:error, :not_found} ->
        render(conn, "delete.json", [])
    end
  end

  defp fetch_package(product_id, version) do
    case Core.get_package_by_version(product_id, version) do
      {:ok, package} ->
        {:ok, Repo.preload(package, [:files, :rollout])}

      other ->
        other
    end
  end

  defp prepare_create(params, product) do
    {:ok,
     params
     |> Map.merge(%{
       "product_id" => product.id,
       "archive" => archive_param(params)
     })}
  end

  defp archive_param(%{"archive" => %Plug.Upload{path: path}}), do: File.read!(path)
  defp archive_param(_), do: nil
end
