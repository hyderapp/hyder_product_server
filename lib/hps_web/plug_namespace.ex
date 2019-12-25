defmodule HPSWeb.Namespace do
  @moduledoc """
  Namespace injecting plug.

  This plug automatically assigns `namespace` into current `Plug.Conn`.
  If the namespace parameter is not presented, the default value will
  be "default".
  """

  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)
    namespace = fetch_from_header(conn.req_headers) || fetch_from_param(conn)

    Logger.debug("namespace: #{namespace}")

    conn
    |> assign(:namespace, namespace)
  end

  @default "default"

  defp fetch_from_header(headers) do
    headers
    |> Enum.find_value(fn
      {"x-hyder-namespace", ns} when is_binary(ns) ->
        ns

      _ ->
        nil
    end)
  end

  defp fetch_from_param(%{params: %{"namespace" => ""}}), do: @default
  defp fetch_from_param(%{params: %{"namespace" => ns}}), do: ns
  defp fetch_from_param(_), do: @default
end
