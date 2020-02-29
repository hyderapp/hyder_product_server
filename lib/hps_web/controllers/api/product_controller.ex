defmodule HPSWeb.API.ProductController do
  use HPSWeb, :controller
  use PhoenixSwagger

  alias HPS.Store.Product

  action_fallback(HPSWeb.FallbackController)

  def swagger_definitions do
    %{
      Product:
        swagger_schema do
          title("Product")
          description("A product is the domain business concept for an application")

          properties do
            name(:string, "product name", required: true)
            title(:string, "description")
          end

          example(%{
            name: "homepage",
            title: "The homepage of my website."
          })
        end,
      Products:
        swagger_schema do
          title("Products")
          description("A collection of products")
          type(:array)
          items(Schema.ref(:Product))
        end
    }
  end

  swagger_path(:index) do
    get("/api/products")
    summary("Get all products")

    description("""
      This api is for end user side use. It returns all available products, and
      the latest versions. Besides, it also returns a `caches` field, indicating
      the cache paths for the benifit of client usage.
    """)

    parameter(:base, :query, :string, "base version in client.",
      description: "used for getting update zip balls.",
      example: "home:1.2.0-sha75xy1zv"
    )

    produces("application/json")
    response(200, "OK", Schema.ref(:Products))
  end

  def index(conn, _params) do
    products =
      Product.list()
      |> Stream.filter(&(&1.namespace == conn.assigns.namespace))
      |> Stream.reject(&(&1.packages == []))

    caches = %{enabled: false, paths: Hyder.Product.all_paths(products)}
    render(conn, "index.json", products: products, caches: caches)
  end
end
