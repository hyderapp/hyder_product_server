defmodule HPS.Store.Product do
  @moduledoc """
  Product store.
  """

  use GenServer

  @name {:via, Registry, {HPS.Registry, :product_store}}

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[name: @name]]}
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  # ----------------------
  #  API
  # ----------------------
  def list, do: GenServer.call(@name, :list)

  def refresh(), do: GenServer.cast(@name, :refresh)

  # ----------------------
  #  callbacks
  # ----------------------
  def init(_) do
    {:ok, reload()}
  end

  def handle_call(:list, _from, state), do: {:reply, state, state}

  def handle_cast(:refresh, _state), do: {:noreply, reload()}

  if Mix.env() == :test do
    defp reload(), do: []
  else
    defp reload(), do: load()
  end

  def load() do
    HPS.Core.list_products(:all)
    |> HPS.Repo.preload(rolled_packages: [:files, :rollout])
    |> Stream.map(fn %{rolled_packages: packages} = product ->
      Map.delete(%{product | packages: packages}, :rolled_packages)
    end)
    |> Enum.map(&HPS.Core.Product.to_hyder_struct/1)
  end
end
