defmodule HPS.Store do
  @moduledoc """
  Stores are the boundaries of core datas.

  Stores provide high level APIs to phoenix controllers. They receive
  API calls from outside, and repsond with datas in memory. In this
  way, it is very fast.

  This design goes reasonable because the data set is very small, and
  reading operations are way more than writing. Every time data gets
  modified, stores will be refreshed.
  """

  def list_products do
    HPS.Store.Product.list()
  end
end
