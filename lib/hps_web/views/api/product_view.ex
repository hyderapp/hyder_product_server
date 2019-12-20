defmodule HPSWeb.API.ProductView do
  use HPSWeb, :view
  alias HPSWeb.API.ProductView

  def render("index.json", %{products: products, caches: caches}) do
    %{
      success: true,
      data: %{
        products: render_many(products, ProductView, "product.json"),
        caches: caches
      }
    }
  end

  def render("show.json", %{product: product}) do
    %{success: true, data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    %{
      name: product.name,
      version: Hyder.Product.latest_package(product).version,
      full_download_url: nil,
      full_download_digest: nil,
      remove: []
    }
  end
end
