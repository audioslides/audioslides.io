defmodule PlatformWeb.Router do
  use PlatformWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PlatformWeb.CurrentUserPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlatformWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PresentationController, :index

    post "/:id/sync", PresentationController, :sync
    post "/:id/generate_video", PresentationController, :generate_video
    resources "/presentations", PresentationController do
      post "/slides/:id/generate_video", SlideController, :generate_video
      resources "/slides", SlideController, only: [:show]
    end
  end

  scope "/auth", PlatformWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end
end
