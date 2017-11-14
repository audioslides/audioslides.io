defmodule Platform.Factory do

  alias Platform.Accounts.Schema.User
  alias Platform.Core.Schema.Course
  alias Platform.Core.Schema.CourseContent
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  # with Ecto
  use ExMachina.Ecto, repo: Platform.Repo

  def course_factory do
    %Course{
      name: "Phoenix Beginner"
    }
  end

  def lesson_factory do
    %Lesson{
      google_presentation_id: sequence(:google_object_id, &"google_object_id-#{&1}"),
      name: "Jane Smith",
      voice_gender: "female",
      voice_language: "de-DE",
      user: build(:user)
    }
  end

  def slide_factory do
    %Slide{
      name: "Introduction",
      google_object_id: sequence(:google_object_id, &"google_object_id-#{&1}"),
      position: sequence(:position, &"#{&1}"),
      lesson: build(:lesson)
    }
  end

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@symetics.com"),
      first_name: sequence(:first_name, &"User FirstName #{&1}"),
      last_name: sequence(:last_name, &"User LastName #{&1}"),
      google_uid: sequence(:google_uid, &"848348018043275321#{&1}"),
    }
  end

  def course_content_factory do
    %CourseContent{
      position: "1",
      course: build(:course),
      lesson: build(:lesson)
    }
  end

end
