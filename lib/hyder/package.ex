defmodule Hyder.Package do
  @moduledoc """
  A Hyder package represents a specifical version of the product.
  """

  defstruct version: nil

  def new(version) do
    %__MODULE__{version: version}
  end
end
