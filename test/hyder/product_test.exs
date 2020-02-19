defmodule HyderProductTest do
  use HPS.DataCase

  alias Hyder.{Product}
  import Hyder.Product
  import HPS.Factory

  doctest Product

  describe "all_paths/2" do
    test "it returns only modified paths from base" do
      product = insert(:product)
      p1 = insert(:package, product: product)

      _file_list_1 =
        for i <- 1..3 do
          insert(:file, package: p1, path: "p1/#{i}/test.html")
        end

      p2 = insert(:package, product: product, online: true)

      _file_list_2 =
        for i <- 1..3 do
          insert(:file, package: p2, path: "p2/#{i}/test.html")
        end

      invalid = %{digest: "hello", path: "/hello.html"}

      insert(:file, Enum.into(invalid, %{package: p1}))
      insert(:file, Enum.into(invalid, %{package: p2}))

      HPS.Core.create_rollout(product, p1)
      HPS.Core.create_rollout(product, p2)

      products = HPS.Store.Product.load()
      assert all_paths(products) == ~w[/p2/1/ /p2/2/ /p2/3/]
    end
  end
end
