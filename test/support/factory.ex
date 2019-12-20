defmodule HPS.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: HPS.Repo

  alias HPS.Core.{Product, Package}

  def product_factory do
    %Product{
      name: sequence(:product_name, &"product-#{&1}"),
      namespace: "default",
      title: "fancy product description"
    }
  end

  def package_factory do
    %Package{
      product: build(:product),
      version: sequence(:version, &"#{&1}")
    }
  end

  def rollout_factory do
  end

  def upload_fixture() do
    %Plug.Upload{
      path: "test/fixtures/shop-v1.0.0-df8d87ef.zip",
      filename: "shop-v1.0.0-df8d87ef.zip"
    }
  end
end
