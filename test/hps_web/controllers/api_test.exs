defmodule HPSWeb.ApiTest do
  use HPS.DataCase

  import HPS.Factory

  describe "index" do
    test "lists all products" do
      p1 = insert(:product, name: "app1")
      p2 = insert(:product, name: "app2", namespace: "ns2")

      rollout(p1, "1.0.0")
      rollout(p2, "5.0.0")

      assert [
               %{name: "app1", namespace: "default"},
               %{name: "app2", namespace: "ns2"}
             ] = HPS.Store.Product.load()
    end
  end

  defp rollout(product, version) do
    pack = insert(:package, product: product, version: version)
    HPS.Core.create_rollout(product, pack)
  end
end
