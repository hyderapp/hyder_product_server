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

    def rollout_fixture(attrs \\ %{}) do
      product = attrs[:product] || insert(:product)
      package = attrs[:package] || insert(:package, product: product)
      insert(:rollout, product: product, package: package, target_version: package.version)
    end

    test "list_rollouts/0 returns all rollouts" do
      rollout = rollout_fixture()
      version = rollout.target_version

      assert [%{target_version: ^version}] = Core.list_rollouts(rollout.product)
    end

    test "get_rollout!/1 returns the rollout with given id" do
      rollout = rollout_fixture()
      id = rollout.id
      assert %{id: ^id} = Core.get_rollout!(rollout.id)
    end

    test "create_rollout/1 with valid data creates a rollout" do
      product = insert(:product)
      package = insert(:package)

      assert {:ok, %Rollout{} = rollout} = Core.create_rollout(product, package)
      assert rollout.policy == "default"
      assert rollout.progress == 1.0
      assert rollout.status == "done"
      refute is_nil(rollout.done_at)
    end

    test "by default policy, create_rollout/1 will get package online" do
      product = insert(:product)
      package = insert(:package, product: product)
      version = package.version

      assert %{online: false} = Core.get_package_by_version!(product, version)

      Core.create_rollout(product, package)
      assert %{online: true} = Core.get_package_by_version!(product, version)
    end

    test "by default policy, create_rollout/1 will get previous package offline" do
      product = insert(:product)
      prev_package = insert(:package, product: product)
      prev_ver = prev_package.version
      Core.create_rollout(product, prev_package)

      package = insert(:package, product: product)
      Core.create_rollout(product, package)

      assert %{online: false} = Core.get_package_by_version!(product, prev_ver)
      assert %{online: true} = Core.get_package_by_version!(product, package.version)
    end

    test "update_rollout/2 with valid data updates the rollout" do
      rollout = rollout_fixture()
      assert {:ok, %Rollout{} = rollout} = Core.update_rollout(rollout, %{progress: 0.8})
      assert rollout.policy == "default"
      assert rollout.progress == 0.8
      assert rollout.status == "active"
    end

    test "update_rollout/2 with invalid data returns error changeset" do
      rollout = rollout_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_rollout(rollout, %{progress: 2.0})
      assert %{progress: 0.0} = Core.get_rollout!(rollout.id)
    end

    test "delete_rollout/1 deletes the rollout" do
      rollout = rollout_fixture()
      assert {:ok, %Rollout{}} = Core.delete_rollout(rollout)
      assert_raise Ecto.NoResultsError, fn -> Core.get_rollout!(rollout.id) end
    end
  end
end
