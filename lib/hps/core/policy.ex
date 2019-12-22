defmodule HPS.Core.Policy do
  @moduledoc """
  Policy defines what strategy is used when rolling out a
  package.
  """

  alias HPS.Core.Rollout

  @type handler :: (Rollout.t() -> term())

  @doc """
  Return the strategy to use when doing a rollout.
  """
  @spec up_strategy(term(), Rollout.t()) :: {handler, handler, handler}
  def up_strategy(policy, rollout) do
    apply(module(policy), :up_strategy, [rollout])
  end

  @doc """
  Return the strategy to use when reverting a rollout.
  """
  @spec down_strategy(term(), Rollout.t()) :: {handler, handler, handler}
  def down_strategy(policy, rollout) do
    apply(module(policy), :down_strategy, [rollout])
  end

  defp module(name) do
    Application.get_env(:hps, :policies)
    |> Keyword.get(String.to_atom(name))
  end
end
