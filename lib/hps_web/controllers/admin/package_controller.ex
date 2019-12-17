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

  def create(conn, %{"package" => params, "product_id" => product_id} = query) do
    ns = Map.get(query, "namespace", "default")

    with {:ok, %Product{} = product} <- Core.get_product_by_name(product_id, ns),
         params = Map.put(params, "product_id", product.id),
         {:ok, %Package{} = package} <- Core.create_package(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.product_package_path(conn, :show, product, package))
      |> render("show.json", package: package)
    end
  end

  def show(conn, %{"id" => id}) do
    package = Core.get_package!(id)
    render(conn, "show.json", package: package)
  end

  def delete(conn, %{"id" => id, "product_id" => product_id}) do
    package = Core.get_package!(id)

    with {:ok, %Package{}} <- Core.delete_package(package) do
      send_resp(conn, :no_content, "")
    end
  end
end
