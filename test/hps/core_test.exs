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
      assert [product] = Core.list_products(product.namespace)
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

    test "create_or_update_package/2 with valid data creates a package" do
      product = insert(:product)

      attrs =
        @valid_attrs
        |> Map.put(:product_id, product.id)
        |> Map.put(:archive, File.read!(upload_fixture().path))

      assert {:ok, %Package{} = package} = Core.create_or_update_package(product, attrs)
      assert package.version == "1.0.0"
    end

    test "create_or_update_package/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Core.create_or_update_package(insert(:product), @invalid_attrs)
    end

    test "delete_package/1 deletes the package" do
      package = package_fixture()
      assert {:ok, %Package{}} = Core.delete_package(package)
      assert_raise Ecto.NoResultsError, fn -> Core.get_package!(package.id) end
    end
  end

  describe "rollouts" do
    alias HPS.Core.Rollout

    @valid_attrs %{policy: "some policy", progress: 120.5, status: "some status"}
    @update_attrs %{policy: "some updated policy", progress: 456.7, status: "some updated status"}
    @invalid_attrs %{policy: nil, progress: nil, status: nil}

    def rollout_fixture(attrs \\ %{}) do
      {:ok, rollout} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_rollout()

      rollout
    end

    test "list_rollouts/0 returns all rollouts" do
      rollout = rollout_fixture()
      assert Core.list_rollouts() == [rollout]
    end

    test "get_rollout!/1 returns the rollout with given id" do
      rollout = rollout_fixture()
      assert Core.get_rollout!(rollout.id) == rollout
    end

    test "create_rollout/1 with valid data creates a rollout" do
      assert {:ok, %Rollout{} = rollout} = Core.create_rollout(@valid_attrs)
      assert rollout.policy == "some policy"
      assert rollout.progress == 120.5
      assert rollout.status == "some status"
    end

    test "create_rollout/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_rollout(@invalid_attrs)
    end

    test "update_rollout/2 with valid data updates the rollout" do
      rollout = rollout_fixture()
      assert {:ok, %Rollout{} = rollout} = Core.update_rollout(rollout, @update_attrs)
      assert rollout.policy == "some updated policy"
      assert rollout.progress == 456.7
      assert rollout.status == "some updated status"
    end

    test "update_rollout/2 with invalid data returns error changeset" do
      rollout = rollout_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_rollout(rollout, @invalid_attrs)
      assert rollout == Core.get_rollout!(rollout.id)
    end

    test "delete_rollout/1 deletes the rollout" do
      rollout = rollout_fixture()
      assert {:ok, %Rollout{}} = Core.delete_rollout(rollout)
      assert_raise Ecto.NoResultsError, fn -> Core.get_rollout!(rollout.id) end
    end

    test "change_rollout/1 returns a rollout changeset" do
      rollout = rollout_fixture()
      assert %Ecto.Changeset{} = Core.change_rollout(rollout)
    end
  end
end
