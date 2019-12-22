defmodule HPSWeb.RequireProduct do
  @moduledoc """
  This plug can be used to ensure product is available in some controllers.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias HPS.Core
  alias HPS.Core.Product

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.params["product_id"] do
      nil ->
        conn
        |> put_status(:expectation_failed)
        |> json(%{success: false, apiMessage: "product name is required"})
        |> halt()

      name ->
        fetch_product(conn, name)
    end
  end

  defp fetch_product(conn, name) do
    name
    |> Core.get_product_by_name(conn.assigns.namespace)
    |> case do
      {:ok, %Product{} = product} ->
        assign(conn, :product, product)

      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, apiMessage: "product not found"})
        |> halt()
    end
  end
end
