defmodule Platform.CoreTest do
  use Platform.DataCase

  alias Platform.Core.Schema.Lesson
  alias Platform.Core

  doctest Platform.Core

  describe "lessons" do

    #@valid_attrs %{google_presentation_id: "some google_presentation_id", name: "some name", voice_gender: "female", voice_language: "en-US"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{google_presentation_id: nil, name: nil, voice_gender: nil, voice_language: nil}

    def lesson_fixture(_attrs \\ %{}) do
      Factory.insert(:lesson)
    end

    # test "list_lessons/0 returns all lessons" do
    #   lesson = lesson_fixture()
    #   assert Core.list_lessons() == [lesson]
    # end

    # test "get_lesson!/1 returns the lesson with given id" do
    #   lesson = lesson_fixture()
    #   assert Core.get_lesson!(lesson.id) == lesson
    # end

    # test "create_lesson/1 with valid data creates a lesson" do
    #   assert {:ok, %Lesson{} = lesson} = Core.create_lesson(@valid_attrs)
    #   assert lesson.google_presentation_id == "some google_presentation_id"
    #   assert lesson.name == "some name"
    #   assert lesson.voice_gender == "female"
    #   assert lesson.voice_language == "en-US"
    # end

    # test "create_lesson/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Core.create_lesson(@invalid_attrs)
    # end

    # test "update_lesson/2 with valid data updates the lesson" do
    #   lesson = lesson_fixture()
    #   assert {:ok, lesson} = Core.update_lesson(lesson, @update_attrs)
    #   assert %Lesson{} = lesson
    #   assert lesson.name == "some updated name"
    # end

    # test "update_lesson/2 with invalid data returns error changeset" do
    #   lesson = lesson_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Core.update_lesson(lesson, @invalid_attrs)
    #   assert lesson == Core.get_lesson!(lesson.id)
    # end

    # test "delete_lesson/1 deletes the lesson" do
    #   lesson = lesson_fixture()
    #   assert {:ok, %Lesson{}} = Core.delete_lesson(lesson)
    #   assert_raise Ecto.NoResultsError, fn -> Core.get_lesson!(lesson.id) end
    # end

    # test "change_lesson/1 returns a lesson changeset" do
    #   lesson = lesson_fixture()
    #   assert %Ecto.Changeset{} = Core.change_lesson(lesson)
    # end
  end

  describe "course_contents" do

    test "should be provide a lesson" do
      lesson = Factory.insert(:lesson)
      course = Factory.insert(:course)
      course_content = course_content_fixture(lesson: lesson, course: course)

      assert course_content.lesson == lesson
    end

    test "should be provide a course" do
      lesson = Factory.insert(:lesson)
      course = Factory.insert(:course)
      course_content = course_content_fixture(lesson: lesson, course: course)

      assert course_content.course == course
    end

  end

  describe "get_course!" do

    test "should return the course by id" do
      course_content = course_content_fixture()
      course_from_db = Core.get_course(course_content.course.id)
      assert course_content.course == course_content.course
    end

  end

  def course_content_fixture(attrs \\ %{}) do
    Factory.insert(:course_content, attrs)
  end
end

