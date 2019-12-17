defmodule HPSWeb.API.ProductController do
  use HPSWeb, :controller

  alias HPS.Store

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products = Store.list_products()
    render(conn, "index.json", products: products)
  end
end
