defmodule HPSWeb.RolloutControllerTest do
  use HPSWeb.ConnCase

  alias HPS.Core

  import HPS.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_rollout]

    test "lists all rollouts", %{conn: conn, product: product, package: package} do
      conn = get(conn, Routes.product_rollout_path(conn, :index, product.name))
      version = package.version

      assert [
               %{
                 "status" => "ready",
                 "target_version" => ^version,
                 "previous_version" => nil
               }
             ] = json_response(conn, 200)["data"]
    end
  end

  describe "create rollout" do
    setup [:create_product]

    test "renders rollout when data is valid", %{conn: conn, product: product, package: package} do
      conn =
        post(conn, Routes.product_rollout_path(conn, :create, product.name),
          version: package.version
        )

      assert true == json_response(conn, 201)["success"]

      conn = get(conn, Routes.product_rollout_path(conn, :show, product.name, package.version))

      assert %{
               "policy" => "default",
               "progress" => 0.0,
               "status" => "ready"
             } = json_response(conn, 200)["data"]
    end

    test "previous_version", %{conn: conn} do
      product = insert(:product)
      prev_package = insert(:package, product: product, online: true, version: "1.0.0")

      insert(:rollout,
        product: product,
        package: prev_package,
        target_version: "1.0.0",
        progress: 1.0,
        status: "done",
        done_at: DateTime.utc_now() |> DateTime.truncate(:second)
      )

      package = insert(:package, product: product, version: "2.5.0")

      conn =
        post(conn, Routes.product_rollout_path(conn, :create, product.name),
          version: package.version
        )

      assert %{
               "policy" => "default",
               "progress" => 0.0,
               "status" => "ready",
               "target_version" => "2.5.0",
               "previous_version" => "1.0.0"
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = post(conn, Routes.product_rollout_path(conn, :create, product.name), [])

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update rollout" do
    setup [:create_rollout]

    test "renders rollout when data is valid", %{
      conn: conn,
      product: product,
      target_version: version
    } do
      conn =
        patch(conn, Routes.product_rollout_path(conn, :update, product.name, version),
          progress: 0.5
        )

      assert json_response(conn, 200)["success"]
      assert %{"progress" => 0.5} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.product_rollout_path(conn, :show, product.name, version))

      assert %{
               "progress" => 0.5,
               "status" => "active",
               "done_at" => nil
             } = json_response(conn, 200)["data"]
    end

    test "update status to `done` when progress is 1.0", %{
      conn: conn,
      product: product,
      target_version: version
    } do
      conn =
        patch(conn, Routes.product_rollout_path(conn, :update, product.name, version),
          progress: 1.0
        )

      assert json_response(conn, 200)["success"]
      assert %{"progress" => 1.0, "status" => "done"} = json_response(conn, 200)["data"]
    end

    test "put package online when update progress", %{
      conn: conn,
      product: product,
      target_version: version
    } do
      patch(conn, Routes.product_rollout_path(conn, :update, product.name, version), progress: 0.5)

      assert {:ok, %{online: true}} = Core.get_package_by_version(product, version)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      product: product,
      target_version: version
    } do
      conn =
        put(conn, Routes.product_rollout_path(conn, :update, product.name, version), progress: 2.0)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete rollout" do
    test "deletes chosen rollout", %{conn: conn, rollout: rollout} do
      conn = delete(conn, Routes.rollout_path(conn, :delete, rollout))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.rollout_path(conn, :show, rollout))
      end)
    end
  end

  defp create_product(_) do
    package = insert(:package)
    {:ok, product: package.product, package: package}
  end

  defp create_rollout(_) do
    package = insert(:package)

    rollout =
      insert(:rollout, product: package.product, package: package, target_version: package.version)

    {:ok, Map.take(rollout, [:product, :package, :target_version])}
  end
end
