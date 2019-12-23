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

  pipeline :doc do
    plug(:accepts, ["html"])

    plug(Plug.Static,
      at: "/",
      from: "priv/static"
    )
  end

  pipeline :health do
    plug(Plug.Logger, log: :debug)
  end

  scope "/", HPSWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/down/*package", DownloadController, :show)
  end

  scope "/health", HPSWeb do
    pipe_through(:health)

    get("/live", HealthController, :show, log: false)
    get("/ready", HealthController, :show, log: false)
  end

  scope "/doc" do
    pipe_through(:doc)

    forward("/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :hps,
      swagger_file: "swagger.json"
    )
  end

  scope "/admin", HPSWeb.Admin do
    pipe_through(:api)

    resources("/products", ProductController, except: [:new, :edit]) do
      resources("/packages", PackageController, except: [:new, :edit])
      resources("/rollouts", RolloutController, except: [:new, :edit, :delete])

      get("/rollout", RolloutController, :show_current)
      delete("/rollout", RolloutController, :rollback_current, as: :rollback)
    end
  end

  scope "/api", HPSWeb.API do
    pipe_through(:api)

    resources("/products", ProductController, only: [:index])
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Hyder Product Server"
      }
    }
  end
end
