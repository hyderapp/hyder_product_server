defmodule HPSWeb.API.ProductView do
  use HPSWeb, :view
  alias HPSWeb.API.ProductView

  import Hyder.Product, only: [latest_package: 1]

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
    version = latest_package(product).version

    %{
      name: product.name,
      version: version,
      full_download_url: full_download_url(product.name, version),
      full_download_digest: nil,
      remove: []
    }
  end

  defp full_download_url(product, version),
    do: Routes.download_url(HPSWeb.Endpoint, :show, [product_package_name(product, version)])

  defp product_package_name(product, version) do
    "#{product}-#{version}.zip"
  end
end
