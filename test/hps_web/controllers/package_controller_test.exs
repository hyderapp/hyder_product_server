defmodule HPSWeb.PackageControllerTest do
  use HPSWeb.ConnCase
  import HPS.Factory

  alias HPS.Core
  alias HPS.Core.Package

  @create_attrs %{
    version: "some version"
  }
  @update_attrs %{
    version: "some updated version"
  }
  @invalid_attrs %{version: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all packages", %{conn: conn} do
      insert(:product, name: "shop")
      conn = get(conn, Routes.product_package_path(conn, :index, "shop"))

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create package" do
    test "renders package when data is valid", %{conn: conn} do
      insert(:product, name: "shop")

      conn =
        post(conn, Routes.product_package_path(conn, :create, "shop"), package: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.product_package_path(conn, :show, "shop", id))

      assert %{
               "id" => id,
               "version" => "some version"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      insert(:product, name: "shop")

      conn =
        post(conn, Routes.product_package_path(conn, :create, "shop"), package: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete package" do
    setup [:create_package]

    test "deletes chosen package", %{conn: conn, package: package} do
      conn = delete(conn, Routes.product_package_path(conn, :delete, package.product, package))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.product_package_path(conn, :show, package.product, package))
      end)
    end
  end

  defp create_package(_) do
    package = insert(:package)
    {:ok, package: package}
  end
end
