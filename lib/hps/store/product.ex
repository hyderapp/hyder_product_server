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

  def list do
    GenServer.call(@name, :list)
  end

  def refresh() do
    GenServer.cast(@name, :refresh)
  end

  def init(_) do
    {:ok, reload()}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:refresh, _from, _state) do
    {:noreply, reload()}
  end

  def reload() do
    HPS.Core.list_products()
  end
end
