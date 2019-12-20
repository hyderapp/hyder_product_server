defmodule HPSWeb.PackageControllerTest do
  use HPSWeb.ConnCase
  import HPS.Factory
  import Routes

  alias HPS.Core
  alias HPS.Core.Package

  @create_attrs %{
    version: "1.0.0"
  }

  @update_attrs %{
    version: "1.2.0"
  }

  @invalid_attrs %{version: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), product: insert(:product)}
  end

  describe "index" do
    test "lists all packages", %{conn: conn, product: product} do
      conn = get(conn, product_package_path(conn, :index, product.name))

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create package" do
    test "renders package when data is valid", %{conn: conn, product: product} do
      attrs =
        @create_attrs
        |> Map.put(:archive, upload_fixture())

      conn = post(conn, product_package_path(conn, :create, product.name), attrs)

      assert %{"version" => version} = json_response(conn, 201)["data"]

      conn = get(conn, product_package_path(conn, :show, product.name, version))

      assert %{"version" => "1.0.0"} = json_response(conn, 200)["data"]
    end

    test "renders errors when file list is empty", %{conn: conn, product: product} do
      conn = post(conn, product_package_path(conn, :create, product.name), @create_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = post(conn, product_package_path(conn, :create, product.name), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete package" do
    setup [:create_package]

    test "deletes chosen package", %{conn: conn, package: package} do
      conn = delete(conn, product_package_path(conn, :delete, package.product, package))
      assert response(conn, 200)

      conn = get(conn, product_package_path(conn, :show, package.product, package))
      assert json_response(conn, 404)
    end
  end

  defp create_package(_) do
    {:ok, package: insert(:package)}
  end
end
