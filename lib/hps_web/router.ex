defmodule HPSWeb.Router do
  use HPSWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", HPSWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/admin", HPSWeb.Admin do
    pipe_through(:api)

    resources("/products", ProductController, only: [:index, :create, :delete, :update])
  end

  scope "/api", HPSWeb.API do
    pipe_through(:api)

    resources("/products", ProductController, only: [:index])
  end
end
