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

    get "/", PageController, :index

    post "/lessons/:id/sync", LessonController, :sync
    post "/lessons/:id/generate_video", LessonController, :generate_video
    resources "/lessons", LessonController do
      post "/slides/:id/generate_video", SlideController, :generate_video
      resources "/slides", SlideController, only: [:show]
    end
    resources "/courses", CourseController
  end

  scope "/auth", PlatformWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end
end
