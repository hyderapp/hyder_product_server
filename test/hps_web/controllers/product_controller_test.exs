defmodule HPSWeb.ProductControllerTest do
  use HPSWeb.ConnCase

  alias HPS.Core

  import HPS.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "it works when empty", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all products", %{conn: conn} do
      insert(:product, name: "app1")
      insert(:product, name: "app2")

      conn = get(conn, Routes.product_path(conn, :index))

      expect = [
        %{
          "name" => "app1",
          "online_packages" => [],
          "title" => "fancy product description"
        },
        %{
          "name" => "app2",
          "online_packages" => [],
          "title" => "fancy product description"
        }
      ]

      assert ^expect = json_response(conn, 200)["data"]
    end

    test "scoped by namespace", %{conn: conn} do
      insert(:product, name: "app1", namespace: "special")

      conn = get(conn, Routes.product_path(conn, :index))
      assert [] == json_response(conn, 200)["data"]

      conn = get(conn, Routes.product_path(conn, :index, namespace: "special"))
      assert [%{"name" => "app1"}] = json_response(conn, 200)["data"]
    end

    test "list online packages", %{conn: conn} do
      insert(:package, online: true, version: "1.0.0")

      conn = get(conn, Routes.product_path(conn, :index))

      assert [%{"online_packages" => [%{"version" => "1.0.0"}]}] =
               json_response(conn, 200)["data"]
    end

    test "create packages with invalid parameters", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create))
      assert false == json_response(conn, 422)["success"]
    end

    test "create packages with valid parameters", %{conn: conn} do
      attrs = %{name: "app", title: "my_app"}
      conn = post(conn, Routes.product_path(conn, :create, attrs))
      assert attrs = json_response(conn, 200)["data"]
    end

    test "create packages within a namespace", %{conn: conn} do
      attrs = %{name: "app", title: "my_app", namespace: "test"}
      post(conn, Routes.product_path(conn, :create, attrs))
      {:ok, product} = Core.get_product_by_name("app", "test")

      assert "test" == product.namespace
      assert "my_app" == product.title
    end
  end
end
