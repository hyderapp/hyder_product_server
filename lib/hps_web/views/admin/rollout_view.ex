defmodule HPSWeb.Admin.RolloutView do
  use HPSWeb, :view
  alias HPSWeb.Admin.RolloutView

  def render("index.json", %{rollouts: rollouts}) do
    %{success: true, data: render_many(rollouts, RolloutView, "rollout.json")}
  end

  def render("show.json", %{rollout: rollout}) do
    %{success: true, data: render_one(rollout, RolloutView, "rollout.json")}
  end

  def render("rollout.json", %{rollout: rollout}) do
    Map.take(rollout, [:status, :progress, :target_version, :previous_version, :policy, :done_at])
  end
end
