defmodule HPSWeb.API.ProductController do
  use HPSWeb, :controller

  alias HPS.Core

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products = Core.list_products()
    render(conn, "index.json", products: products)
  end
end
