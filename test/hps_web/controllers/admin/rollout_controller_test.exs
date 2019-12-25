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
               "progress" => 1.0,
               "status" => "done"
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
        done_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
      )

      package = insert(:package, product: product, version: "2.5.0")

      conn =
        post(conn, Routes.product_rollout_path(conn, :create, product.name),
          version: package.version
        )

      assert %{
               "policy" => "default",
               "progress" => 1.0,
               "status" => "done",
               "target_version" => "2.5.0",
               "previous_version" => "1.0.0"
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = post(conn, Routes.product_rollout_path(conn, :create, product.name), [])

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show current" do
    setup [:create_product]

    test "it returns emtpy when no rollout availble", %{conn: conn, product: product} do
      conn = get(conn, Routes.product_rollout_path(conn, :show_current, product.name))

      assert json_response(conn, 200)["data"] == nil
    end

    test "it returns the most recent done rollout", %{conn: conn, product: product} do
      p1 = insert(:package, product: product, version: "1.1.0", online: false)
      t = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:microsecond)
      release_package(product, p1, done_at: t)

      p2 = insert(:package, product: product, version: "1.2.0", online: true)
      release_package(product, p2)

      conn = get(conn, Routes.product_rollout_path(conn, :show_current, product.name))

      assert %{"target_version" => "1.2.0"} = json_response(conn, 200)["data"]
    end
  end

  describe "rollback" do
    setup [:create_product]

    test "no rollout to rollback", %{conn: conn, product: product} do
      conn = delete(conn, Routes.product_rollback_path(conn, :rollback_current, product.name))
      assert json_response(conn, 422)
    end

    test "rollback current rollout", %{conn: conn, product: product} do
      p = insert(:package, product: product, online: true)
      version = p.version
      release_package(product, p)

      assert {:ok, %{online: true}} = Core.get_package_by_version(product, version)

      conn = delete(conn, Routes.product_rollback_path(conn, :rollback_current, product.name))

      assert json_response(conn, 200)["success"]

      assert Core.get_rollout_by_version(product, version) == nil
      assert {:ok, %{online: false}} = Core.get_package_by_version(product, version)
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

  defp release_package(product, package, opts \\ []) do
    opts =
      [
        product: product,
        package: package,
        target_version: package.version,
        status: "done",
        progress: 1.0,
        done_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
      ]
      |> Keyword.merge(opts)

    insert(:rollout, opts)
  end
end
