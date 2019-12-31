defmodule HPS.Store.Product do
  @moduledoc """
  Product store.
  """

  use GenServer
  require Logger

  @name __MODULE__

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[name: @name]]}
    }
  end

  def start_link(opts) do
    :ok = :pg2.create(__MODULE__)

    GenServer.start_link(__MODULE__, [], opts)
  end

  # ----------------------
  #  API
  # ----------------------
  def list, do: GenServer.call(@name, :list)

  def refresh(), do: GenServer.call(@name, :refresh)

  # ----------------------
  #  callbacks
  # ----------------------
  def init(_) do
    :pg2.join(__MODULE__, self())
    {:ok, reload()}
  end

  def handle_call(:list, _from, state), do: {:reply, state, state}

  def handle_call(:refresh, _from, _state) do
    for pid <- :pg2.get_members(__MODULE__), pid != self() do
      send(pid, :reload)
    end

    {:reply, :ok, reload()}
  end

  def handle_info(:reload, _state) do
    {:noreply, reload()}
  end

  if Mix.env() == :test do
    defp reload(), do: []
  else
    defp reload(), do: load()
  end

  def load() do
    Logger.info("rebuild cache")

    HPS.Core.list_products(:all)
    |> HPS.Repo.preload(rolled_packages: [:files, :rollout])
    |> Stream.map(fn %{rolled_packages: packages} = product ->
      Map.delete(%{product | packages: packages}, :rolled_packages)
    end)
    |> Enum.map(&HPS.Core.Product.to_hyder_struct/1)
  end
end
