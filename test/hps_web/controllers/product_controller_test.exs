defmodule HPSWeb.ProductControllerTest do
  use HPSWeb.ConnCase

  alias HPS.Core
  alias HPS.Core.Product

  @create_attrs %{
    name: "some name",
    namespace: "some namespace",
    title: "some title"
  }
  @update_attrs %{
    name: "some updated name",
    namespace: "some updated namespace",
    title: "some updated title"
  }
  @invalid_attrs %{name: nil, namespace: nil, title: nil}

  def fixture(:product) do
    {:ok, product} = Core.create_product(@create_attrs)
    product
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
