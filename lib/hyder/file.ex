defmodule Hyder.File do
  @moduledoc """
  This module represents the File concept of Hyder products.

  A file is an entry used by a package. A package may contains one
  or more files. Each file may have same or different `content`,
  but they can have unique `path` within one package.
  """

  @type t :: %Hyder.File{
          path: binary(),
          content: binary() | nil,
          digest: binary(),
          size: non_neg_integer()
        }

  defstruct [:path, :content, :digest, :size]
end
