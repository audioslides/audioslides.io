defmodule Platform.CoreTest do
  use Platform.DataCase

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide
  alias Platform.GoogleSlidesFactory

  import Mox

  setup :verify_on_exit!

  doctest Platform.Core

  describe "lessons" do
    @valid_attrs %{
      google_presentation_id: "some-google_presentation_id",
      name: "some name",
      voice_gender: "female",
      voice_language: "en-US"
    }
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{
      google_presentation_id: nil,
      name: nil,
      voice_gender: nil,
      voice_language: nil
    }

    test "list_lessons/0 returns all lessons" do
      lesson = Factory.insert(:lesson)
      lessons = Core.list_lessons()
      assert length(lessons) == 1
      assert List.first(lessons).id == lesson.id
    end

    test "list_visible_lessons/0 return only visible lessons" do
      lesson = Factory.insert(:lesson, visible: true)
      Factory.insert(:lesson, visible: true)
      Factory.insert(:lesson, visible: false)

      lessons = Core.list_visible_lessons()
      assert length(lessons) == 2
      assert List.first(lessons).id == lesson.id
    end

    test "get_lesson!/1 returns the lesson with given id" do
      lesson = Factory.insert(:lesson)
      assert Core.get_lesson!(lesson.id).id == lesson.id
    end

    test "get_lesson_by_google_presentation_id!/1 returns the lesson with given id" do
      lesson = Factory.insert(:lesson)

      assert Core.get_lesson_by_google_presentation_id!(lesson.google_presentation_id).id == lesson.id
    end

    test "create_lesson/1 with valid data creates a lesson" do
      assert {:ok, %Lesson{} = lesson} = Core.create_lesson(@valid_attrs)
      assert lesson.google_presentation_id == "some-google_presentation_id"
      assert lesson.name == "some name"
      assert lesson.voice_gender == "female"
      assert lesson.voice_language == "en-US"
    end

    test "create_lesson/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_lesson(@invalid_attrs)
    end

    test "update_lesson/2 with valid data updates the lesson" do
      lesson = Factory.insert(:lesson)
      assert {:ok, lesson} = Core.update_lesson(lesson, @update_attrs)
      assert %Lesson{} = lesson
      assert lesson.name == "some updated name"
    end

    test "update_lesson/2 with invalid data returns error changeset" do
      lesson = Factory.insert(:lesson)
      assert {:error, %Ecto.Changeset{}} = Core.update_lesson(lesson, @invalid_attrs)
      assert lesson.id == Core.get_lesson!(lesson.id).id
    end

    test "delete_lesson/1 deletes the lesson" do
      lesson = Factory.insert(:lesson)
      assert {:ok, %Lesson{}} = Core.delete_lesson(lesson)
      assert_raise Ecto.NoResultsError, fn -> Core.get_lesson!(lesson.id) end
    end

    test "change_lesson/1 returns a lesson changeset" do
      lesson = Factory.insert(:lesson)
      assert %Ecto.Changeset{} = Core.change_lesson(lesson)
    end

    test "sync_lesson/1 sync lessons" do
      lesson = Factory.insert(:lesson)

      google_slide1 =
        GoogleSlidesFactory.get_base_slide(
          object_id: "objID_1",
          content: "Example Content 1",
          speaker_notes: "Speaker Notes 1"
        )

      google_slide2 =
        GoogleSlidesFactory.get_base_slide(
          object_id: "objID_2",
          content: "Example Content 2",
          speaker_notes: "Speaker Notes 2"
        )

      google_lesson = %GoogleApi.Slides.V1.Model.Presentation{
        presentationId: lesson.google_presentation_id,
        slides: [google_slide1, google_slide2]
      }

      Core.sync_lesson(google_lesson)

      lesson =
        lesson
        |> Repo.preload(:slides)

      assert length(lesson.slides) == 2

      assert Enum.map(lesson.slides, fn slide -> slide.google_object_id end) == [
               "objID_1",
               "objID_2"
             ]
    end

    test "download_slide_thumb/1 download all thumbs" do
      slide1 = Factory.insert(:slide)
      slide2 = Factory.insert(:slide)
      lesson = Factory.insert(:lesson, slides: [slide1, slide2])

      Platform.SlidesAPIMock
      |> expect(:download_slide_thumb!, length(lesson.slides), fn _x, _y, z -> z end)

      Core.download_all_thumbs!(lesson)
    end

    test "invalidate_all_audio_hashes/1" do
      slide1 = Factory.insert(:slide, audio_hash: "VALID_HASH")
      slide2 = Factory.insert(:slide, audio_hash: "VALID_HASH")
      lesson = Factory.insert(:lesson, slides: [slide1, slide2])

      Core.invalidate_all_audio_hashes(lesson)

      lesson = Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn slide -> slide.audio_hash end) == [nil, nil]
    end

    test "invalidate_all_video_hashes/1" do
      slide1 = Factory.insert(:slide, audio_hash: "VALID_HASH")
      slide2 = Factory.insert(:slide, audio_hash: "VALID_HASH")
      lesson = Factory.insert(:lesson, slides: [slide1, slide2])

      Core.invalidate_all_video_hashes(lesson)

      lesson = Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn slide -> slide.video_hash end) == [nil, nil]
    end

    test "invalidate_all_image_hashes/1" do
      slide1 = Factory.insert(:slide, image_hash: "VALID_HASH")
      slide2 = Factory.insert(:slide, image_hash: "VALID_HASH")
      lesson = Factory.insert(:lesson, slides: [slide1, slide2])

      Core.invalidate_all_image_hashes(lesson)

      lesson = Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn slide -> slide.image_hash end) == [nil, nil]
    end

    test "invalidate_image_hash/1" do
      slide = Factory.insert(:slide, image_hash: "VALID_HASH")

      Core.invalidate_image_hash(slide)

      slide = Core.get_slide!(slide.id)

      assert slide.image_hash == nil
    end

    test "invalidate_audio_hash/1" do
      slide = Factory.insert(:slide, audio_hash: "VALID_HASH")

      Core.invalidate_audio_hash(slide)

      slide = Core.get_slide!(slide.id)

      assert slide.audio_hash == nil
    end

    test "invalidate_video_hash/1" do
      slide = Factory.insert(:slide, video_hash: "VALID_HASH")

      Core.invalidate_video_hash(slide)

      slide = Core.get_slide!(slide.id)

      assert slide.video_hash == nil
    end
  end

  describe "slides" do
    @valid_attrs %{google_object_id: "some google_object_id", name: "some name", position: "1"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{google_presentation_id: nil, name: nil, position: nil}

    # test "list_slides/0 returns all slides" do
    #   slide = Factory.insert(:slide)
    #   slides = Core.list_slides()
    #   assert length(slides) == 1
    #   assert List.first(slides).id == slide.id
    # end

    # test "get_slide!/1 returns the slide with given id" do
    #   slide = Factory.insert(:slide)
    #   assert Core.get_slide!(slide.id).id == slide.id
    # end

    test "create_slide/1 with valid data creates a slide" do
      lesson = Factory.insert(:lesson)
      assert {:ok, %Slide{} = slide} = Core.create_slide(lesson, @valid_attrs)
      assert slide.google_object_id == "some google_object_id"
      assert slide.name == "some name"
    end

    test "create_slide/1 with invalid data returns error changeset" do
      lesson = Factory.insert(:lesson)
      assert {:error, %Ecto.Changeset{}} = Core.create_slide(lesson, @invalid_attrs)
    end

    test "update_slide/2 with valid data updates the slide" do
      slide = Factory.insert(:slide)
      assert {:ok, slide} = Core.update_slide(slide, @update_attrs)
      assert %Slide{} = slide
      assert slide.name == "some updated name"
    end

    test "update_slide/2 with invalid data returns error changeset" do
      slide = Factory.insert(:slide)
      assert {:error, %Ecto.Changeset{}} = Core.update_slide(slide, @invalid_attrs)
      assert slide.id == Core.get_slide!(slide.id).id
    end

    test "delete_slide/1 deletes the slide" do
      lesson = Factory.insert(:lesson)
      slide = Factory.insert(:slide, lesson: lesson)
      assert {:ok, %Slide{}} = Core.delete_slide(lesson, slide)
      assert_raise Ecto.NoResultsError, fn -> Core.get_slide!(slide.id) end
    end

    test "change_slide/1 returns a slide changeset" do
      lesson = Factory.insert(:lesson)
      slide = Factory.insert(:slide)
      assert %Ecto.Changeset{} = Core.change_slide(lesson, slide)
    end

    test "update_slide_audio_hash/2 with valid data updates the slide" do
      slide = Factory.insert(:slide)
      assert {:ok, slide} = Core.update_slide_audio_hash(slide, "NEW_HASH")
      assert slide.audio_hash == "NEW_HASH"
    end

    test "update_slide_image_hash/2 with valid data updates the slide" do
      slide = Factory.insert(:slide)
      assert {:ok, slide} = Core.update_slide_image_hash(slide, "NEW_HASH")
      assert slide.image_hash == "NEW_HASH"
    end

    test "update_slide_video_hash/2 with valid data updates the slide" do
      slide = Factory.insert(:slide)
      assert {:ok, slide} = Core.update_slide_video_hash(slide, "NEW_HASH")
      assert slide.video_hash == "NEW_HASH"
    end
  end

  describe "course_lessons" do
    test "should be provide a lesson" do
      lesson = Factory.insert(:lesson)
      course = Factory.insert(:course)
      course_lesson = Factory.insert(:course_lesson, lesson: lesson, course: course)

      assert course_lesson.lesson == lesson
    end

    test "should be provide a course" do
      lesson = Factory.insert(:lesson)
      course = Factory.insert(:course)
      course_lesson = Factory.insert(:course_lesson, lesson: lesson, course: course)

      assert course_lesson.course == course
    end
  end

  describe "get_course!" do
    test "should return the course by id" do
      course_lesson = Factory.insert(:course_lesson)
      course_from_db = Core.get_course!(course_lesson.course.id)
      assert course_lesson.course.id == course_from_db.id
    end
  end

  describe "get_course_with_lessons!" do
    test "should return the course by id" do
      course_lesson = Factory.insert(:course_lesson)
      course_from_db = Core.get_course_with_lessons!(course_lesson.course.id)
      assert course_lesson.course.id == course_from_db.id
    end
  end
end
