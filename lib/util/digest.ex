defmodule Hyder.Util.Digest do
  @moduledoc """
  Digest method used in hyder.
  """

  def hash(content) do
    :crypto.hash(:sha256, content) |> Base.encode32(case: :lower, padding: false)
  end
end
