defmodule HPSWeb.Namespace do
  @moduledoc """
  Namespace injecting plug.

  This plug automatically assigns `namespace` into current `Plug.Conn`.
  If the namespace parameter is not presented, the default value will
  be "default".
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)
    namespace = fetch_ns(conn)

    conn
    |> assign(:namespace, namespace)
  end

  @default "default"

  defp fetch_ns(%{req_params: %{"namespace" => ""}}), do: @default
  defp fetch_ns(%{req_params: %{"namespace" => ns}}), do: ns
  defp fetch_ns(_), do: @default
end
