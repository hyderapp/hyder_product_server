defmodule HPS.CoreTest do
  use HPS.DataCase

  import HPS.Factory

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
      assert Core.list_products(product.namespace) == [product]
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

  describe "packages" do
    alias HPS.Core.Package

    @valid_attrs %{version: "1.0.0"}
    @update_attrs %{version: "1.2.3"}
    @invalid_attrs %{version: nil}

    def package_fixture(attrs \\ %{}) do
      insert(:package, attrs)
    end

    test "list_packages/1 returns all packages of a product" do
      package = package_fixture(version: "1.10")
      assert [%Package{version: "1.10"}] = Core.list_packages(package.product)

      assert Core.list_packages(insert(:product)) == []
    end

    test "get_package!/1 returns the package with given id" do
      package = package_fixture()
      ret = Core.get_package!(package.id)

      assert ret.version == package.version
    end

    test "create_package/1 with valid data creates a package" do
      product = insert(:product)
      attrs = Map.put(@valid_attrs, :product_id, product.id)
      assert {:ok, %Package{} = package} = Core.create_package(attrs)
      assert package.version == "1.0.0"
    end

    test "create_package/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_package(@invalid_attrs)
    end

    test "delete_package/1 deletes the package" do
      package = package_fixture()
      assert {:ok, %Package{}} = Core.delete_package(package)
      assert_raise Ecto.NoResultsError, fn -> Core.get_package!(package.id) end
    end
  end
end
