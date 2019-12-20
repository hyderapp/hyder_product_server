defmodule HPSWeb.API.ProductController do
  use HPSWeb, :controller

  alias HPS.Store.Product

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products =
      Product.list()
      |> Enum.filter(&(&1.namespace == conn.assigns.namespace))

    caches = %{enabled: true, paths: []}
    render(conn, "index.json", products: products, caches: caches)
  end
end
