defmodule HPSWeb.Admin.ProductView do
  use HPSWeb, :view
  alias HPSWeb.Admin.ProductView

  def render("index.json", %{products: products}) do
    %{success: true, data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{succeess: true, data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    %{name: product.name, title: product.title}
  end
end
