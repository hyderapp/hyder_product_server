defmodule HPSWeb.Admin.PackageController do
  use HPSWeb, :controller

  alias HPS.Core
  alias HPS.Core.{Product}

  action_fallback(HPSWeb.FallbackController)

  def index(conn, %{"product_id" => product_id}) do
    with {:ok, %Product{} = product} <- fetch_product(product_id, conn),
         packages <- Core.list_packages(product) do
      conn
      |> render("index.json", packages: packages)
    end
  end

  def create(conn, %{"product_id" => product_id} = params) do
    with {:ok, product} <- fetch_product(product_id, conn),
         {:ok, params} <- prepare_create(params, product),
         {:ok, package} <- Core.create_or_update_package(product, params) do
      conn
      |> put_status(:created)
      |> render("show.json", package: package)
    end
  end

  def show(conn, %{"id" => id, "product_id" => product_id}) do
    with {:ok, product} <- fetch_product(product_id, conn),
         {:ok, package} <- Core.get_package_by_version(product.id, id) do
      conn
      |> render("show.json", package: package)
    end
  end

  def delete(conn, %{"id" => id, "product_id" => product_id}) do
    with {:ok, product} <- fetch_product(product_id, conn),
         {:ok, package} <- Core.get_package_by_version(product.id, id),
         {:ok, _} <- Core.delete_package(package) do
      conn
      |> render("delete.json", [])
    else
      {:error, :not_found} ->
        render(conn, "delete.json", [])
    end
  end

  defp fetch_product(id, conn) do
    Core.get_product_by_name(id, conn.assigns.namespace)
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
