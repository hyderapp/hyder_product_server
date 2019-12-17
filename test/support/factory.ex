defmodule HPS.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: HPS.Repo

  alias HPS.Core.{Product, Package}

  def product_factory do
    %Product{
      name: sequence(:product_name, &"product-#{&1}"),
      namespace: sequence(:namespace, ~w[default stg stg-1 stg-5 pre]),
      title: "fancy product description"
    }
  end

  def package_factory do
    %Package{
      product: build(:product),
      version: sequence(:version, &"#{&1}")
    }
  end
end
