defmodule Hyder.Rollout do
  @moduledoc """
  Hyder Rollout represents the concept of the releasing processes.

  In order to make a package available to users, you need to build
  a rollout for the package. When the rollout is finished, the package
  will be added to product's packages list.

  Rollout is initialized with a progress of `0`. When progress reaches
  `1`, the releaseing progress is then finished.

  There are different status of a rollout:

  * `ready` - the rollout is initialized, ready to deploy;
  * `active` - the rollout is being deployed, but not finished;
  * `done` - the rollout is fully deployed to all users.
  """

  defstruct [:status, :progress, :policy]
end
