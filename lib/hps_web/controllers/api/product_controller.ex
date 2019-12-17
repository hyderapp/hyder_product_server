defmodule HPSWeb.API.ProductController do
  use HPSWeb, :controller

  alias HPS.Store.Product

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products = Product.list()
    render(conn, "index.json", products: products)
  end
end
