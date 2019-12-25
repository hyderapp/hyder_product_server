defmodule HPSWeb.Admin.ProductController do
  use HPSWeb, :controller

  alias HPS.Core

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products =
      conn.assigns.namespace
      |> Core.list_products()
      |> HPS.Repo.preload(:online_packages)

    render(conn, "index.json", products: products)
  end

  def create(conn, params) do
    with {:ok, product} <- Core.create_product(params) do
      render(conn, "show.json", product: product)
    end
  end

  def show(conn, %{"name" => name}) do
    preload = :online_packages

    with {:ok, product} <-
           Core.get_product_by_name(name, conn.assigns.namespace, preload: preload) do
      conn
      |> render("show.json", product: product)
    end
  end
end
