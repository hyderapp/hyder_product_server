defmodule HPS.Core.OnlineOfflineTest do
  use HPS.DataCase

  alias HPS.Core

  import HPS.Factory

  setup do
    {:ok, %{product: insert(:product)}}
  end

  describe "put_package_online/2" do
    test "at the beginning, there is no online package", %{product: product} do
      assert Core.online_packages(product) == []
    end

    test "before putting package online, there is no online package", %{product: product} do
      insert(:package, product: product)
      assert Core.online_packages(product) == []
    end

    test "after putting a package online, there is an online package", %{product: product} do
      insert(:package, product: product, version: "3.0.0")
      assert :ok == Core.put_package_online(product, "3.0.0")
      assert Core.online_packages(product) |> Enum.map(& &1.version) == ["3.0.0"]
    end

    test "all other packages go offline after releasing a package", %{product: product} do
      insert(:package, product: product, version: "1.0.0", online: true)
      insert(:package, product: product, version: "2.0.0", online: false)
      insert(:package, product: product, version: "3.0.0")

      assert :ok == Core.put_package_online(product, "3.0.0")
      assert ["3.0.0"] == online_versions(product)

      refute pkg(product, "1.0.0").online
      refute pkg(product, "2.0.0").online
      assert pkg(product, "3.0.0").online
    end
  end

  describe "put_package_offline/2" do
    test "putting a package whose status is offline", %{product: product} do
      insert(:package, product: product, version: "1.0.0")

      assert :ok == Core.put_package_offline(product, "1.0.0")
      assert [] == Core.online_packages(product)
    end

    test "next highest versioned package will come up", %{product: product} do
      insert(:package, product: product, version: "1.0.0")
      insert(:package, product: product, version: "2.0.0", online: true)
      insert(:package, product: product, version: "3.0.0")

      assert :ok == Core.put_package_offline(product, "2.0.0")
      assert ["1.0.0"] == online_versions(product)
    end
  end

  defp pkg(product, ver) do
    {:ok, p} = Core.get_package_by_version(product, ver)
    p
  end

  defp online_versions(product) do
    product.id
    |> Core.get_product!()
    |> Core.online_packages()
    |> Enum.map(& &1.version)
  end
end
