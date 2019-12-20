defmodule HPSWeb.Admin.PackageController do
  use HPSWeb, :controller

  alias HPS.Core
  alias HPS.Core.{Product, Package}

  action_fallback(HPSWeb.FallbackController)

  def index(conn, %{"product_id" => product_id} = params) do
    with {:ok, %Product{} = product} <- Core.get_product_by_name(product_id),
         packages <- Core.list_packages(product) do
      conn
      |> render("index.json", packages: packages)
    end
  end

  def create(conn, %{"product_id" => _product_id} = params) do
    with {:ok, %Product{} = product} <- fetch_product(params, conn),
         params = %{params | "product_id" => product.id},
         {:ok, %Package{} = package} <- Core.create_package(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.product_package_path(conn, :show, product, package))
      |> render("show.json", package: package)
    end
  end

  def show(conn, %{"id" => id, "product_id" => _product_id} = params) do
    with {:ok, %Product{} = product} <- fetch_product(params, conn),
         {:ok, %Package{} = package} <- Core.get_package_by_version(product.id, id) do
      conn
      |> render("show.json", package: package)
    end
  end

  def delete(conn, %{"id" => id}) do
    package = Core.get_package!(id)

    with {:ok, %Package{}} <- Core.delete_package(package) do
      send_resp(conn, :no_content, "")
    end
  end

  defp fetch_product(%{"product_id" => id}, conn) do
    Core.get_product_by_name(id, conn.assigns.namespace)
  end
end
