defmodule HPSWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use HPSWeb.ConnCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias HPSWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint HPSWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HPS.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(HPS.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn() |> use_basic_auth()}
  end

  defp use_basic_auth(conn) do
    {user, name} = Application.get_env(:hps, :basic_auth_wl, [{"test", "test"}]) |> hd()
    content = Base.encode64("#{user}:#{name}")

    conn
    |> Plug.Conn.put_req_header("authorization", "Basic #{content}")
  end
end
