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
    get("/down/*package", DownloadController, :show)
  end

  scope "/admin", HPSWeb.Admin do
    pipe_through(:api)

    resources("/products", ProductController, except: [:new, :edit]) do
      resources("/packages", PackageController, except: [:new, :edit])
    end
  end

  scope "/api", HPSWeb.API do
    pipe_through(:api)

    resources("/products", ProductController, only: [:index])
  end
end
