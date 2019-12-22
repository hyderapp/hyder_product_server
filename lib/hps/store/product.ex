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
    defp reload() do
      HPS.Core.list_products()
      |> HPS.Repo.preload(online_packages: :files)
      |> Enum.map(fn %{online_packages: packages} = product ->
        Map.delete(%{product | packages: packages}, :online_packages)
      end)
    end
  end
end
