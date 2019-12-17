defmodule HPSWeb.ProductView do
  use HPSWeb, :view
  alias HPSWeb.ProductView

  def render("index.json", %{products: products}) do
    %{data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    %{id: product.id, namespace: product.namespace, name: product.name, title: product.title}
  end
end
