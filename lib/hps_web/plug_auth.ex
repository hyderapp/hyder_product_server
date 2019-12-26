defmodule HPSWeb.Auth do
  @moduledoc """
  This is the plug for admin auth.
  """

  import Plug.Crypto, only: [secure_compare: 2]
  import Plug.Conn

  @whitelist Application.get_env(:hps, :basic_auth_wl, [])
             |> Enum.map(fn {u, pwd} -> u <> "\0" <> pwd end)

  def authorize_user(conn, user, pwd) do
    if Enum.any?(@whitelist, &secure_compare(&1, user <> "\0" <> pwd)) do
      conn |> assign(:current_user_name, user)
    else
      conn |> halt()
    end
  end
end
