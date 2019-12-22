defmodule HyderProductTest do
  use HPS.DataCase

  alias Hyder.{Product}
  import Hyder.Product
  import HPS.Factory

  doctest Product

  describe "all_paths/2" do
    test "it return only modified paths from base" do
      product = insert(:product)
      p1 = insert(:package, product: product)

      _file_list_1 =
        for _ <- 1..3 do
          insert(:file, package: p1)
        end

      p2 = insert(:package, product: product, online: true)

      _file_list_2 =
        for _ <- 1..3 do
          insert(:file, package: p2)
        end

      common_file = %{digest: "hello", path: "/hello"}

      insert(:file, Enum.into(common_file, %{package: p1}))
      insert(:file, Enum.into(common_file, %{package: p2}))

      HPS.Core.create_rollout(product, p1)
      HPS.Core.create_rollout(product, p2)

      products = HPS.Store.Product.load()
      paths = all_paths(products, %{product.name => p1.version})
      assert(length(paths) == 3)

      assert length(all_paths(products)) == 4
    end
  end
end
