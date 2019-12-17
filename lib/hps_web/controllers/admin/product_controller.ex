defmodule HPSWeb.Admin.ProductController do
  use HPSWeb, :controller

  alias HPS.Core

  action_fallback(HPSWeb.FallbackController)

  def index(conn, params) do
    products = params |> ns() |> Core.list_products()
    render(conn, "index.json", products: products)
  end

  def create(conn, params) do
    with {:ok, product} <- Core.create_product(params) do
      render(conn, "show.json", product: product)
    end
  end

  def show(conn, %{"id" => id} = params) do
    with {:ok, product} <- Core.get_product_by_name(id, ns(params)) do
      conn
      |> render("show.json", product: product)
    end
  end

  defp ns(%{"namespace" => ns}), do: ns
  defp ns(_), do: "default"
end
