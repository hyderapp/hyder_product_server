defmodule HPS.CoreTest do
  use HPS.DataCase

  alias HPS.Core

  describe "products" do
    alias HPS.Core.Product

    @valid_attrs %{name: "some name", namespace: "some namespace", title: "some title"}
    @update_attrs %{
      name: "some updated name",
      namespace: "some updated namespace",
      title: "some updated title"
    }
    @invalid_attrs %{name: nil, namespace: nil, title: nil}

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Core.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Core.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Core.create_product(@valid_attrs)
      assert product.name == "some name"
      assert product.namespace == "some namespace"
      assert product.title == "some title"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_product(@invalid_attrs)
    end

    test "update_product/2, name and namespace are will not be updated" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Core.update_product(product, @update_attrs)
      assert product.name == "some name"
      assert product.namespace == "some namespace"
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Core.update_product(product, @update_attrs)
      assert product.title == "some updated title"
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Core.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Core.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Core.change_product(product)
    end
  end
end
