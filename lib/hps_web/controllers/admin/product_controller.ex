defmodule HPSWeb.Admin.ProductController do
  use HPSWeb, :controller

  alias HPS.Core

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products = Core.list_products()
    render(conn, "index.json", products: products)
  end

  def create(conn, params) do
    with {:ok, product} <- Core.create_product(params) do
      render(conn, "show.json", product: product)
    end
  end
end
