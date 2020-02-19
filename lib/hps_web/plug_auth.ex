defmodule HPSWeb.Auth do
  @moduledoc """
  This is the plug for admin auth.
  """

  @whitelist Application.get_env(:hps, :basic_auth_wl, [])
             |> Enum.map(fn {u, pwd} -> u <> "\0" <> pwd end)

  case @whitelist do
    [] ->
      def authorize_user(conn, _, _), do: conn

    _ ->
      def authorize_user(conn, user, pwd) do
        if Enum.any?(@whitelist, &Plug.Crypto.secure_compare(&1, user <> "\0" <> pwd)) do
          conn |> Plug.Conn.assign(:current_user_name, user)
        else
          conn |> Plug.Conn.halt()
        end
      end
  end

  def unauthorized_response(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, ~s[{"success":false,"apiMessage": "Unauthorized"}])
  end
end
