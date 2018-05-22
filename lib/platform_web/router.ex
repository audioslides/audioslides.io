defmodule PlatformWeb.Router do
  use PlatformWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(PlatformWeb.CurrentUserPlug)
  end

  pipeline :basic_auth do
    # if Mix.env == :prod do
      plug PlatformWeb.BasicAuthPlug, username: "audioslides", password: "demo"
    # end
  end

  scope "/", PlatformWeb do
    # Use the default browser stack
    pipe_through([:browser, :basic_auth])

    get("/", PageController, :index)

    post "/lessons/:id/sync", LessonController, :sync
    post"/lessons/:id/generate_video", LessonController, :generate_video

    post"/lessons/:id/invalidate_all_audio_hashes", LessonController, :invalidate_all_audio_hashes
    post"/lessons/:id/invalidate_all_video_hashes", LessonController, :invalidate_all_video_hashes

    post"/lessons/:id/download_all_thumbs", LessonController, :download_all_thumbs
    get"/lessons/:id/manage", LessonController, :manage

    resources "/lessons", LessonController do
      post "/slides/:id/generate_video", SlideController, :generate_video
      resources "/slides", SlideController, only: [:show, :edit, :update]
    end

    resources "/courses", CourseController do
      resources "/lessons", CourseLessonController
    end

    get "/imprint", StaticPageController, :imprint
    get "/privacy", StaticPageController, :privacy
  end

  scope "/auth", PlatformWeb do
    pipe_through([:browser, :basic_auth])

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end
end
