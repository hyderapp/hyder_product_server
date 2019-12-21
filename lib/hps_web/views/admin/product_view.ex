defmodule HPSWeb.Admin.ProductView do
  use HPSWeb, :view
  alias HPSWeb.Admin.ProductView
  alias HPSWeb.Admin.PackageView

  def render("index.json", %{products: products}) do
    %{success: true, data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{succeess: true, data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    product
    |> Map.take([:name, :title, :online_packages])
    |> with_online_packages()
  end

  # defp with_online_packages(%{online_packages: packages} = map) when is_list(packages), do: map
  defp with_online_packages(%{online_packages: packages} = map) when is_list(packages) do
    Map.update!(map, :online_packages, &render_many(&1, PackageView, "package.json"))
  end

  defp with_online_packages(map), do: Map.delete(map, :online_packages)
end
