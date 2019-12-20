defmodule HPSWeb.API.ProductController do
  use HPSWeb, :controller

  alias HPS.Store.Product

  action_fallback(HPSWeb.FallbackController)

  def index(conn, _params) do
    products =
      Product.list()
      |> Stream.filter(&(&1.namespace == conn.assigns.namespace))
      |> Stream.reject(&(&1.packages == []))

    caches = %{enabled: true, paths: Hyder.Product.all_paths(products)}
    render(conn, "index.json", products: products, caches: caches)
  end
end
