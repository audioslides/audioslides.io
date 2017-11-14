defmodule Platform.GoogleSlides do
  @moduledoc """
  The google slides context
  """

  alias Goth.Token
  alias GoogleApi.Slides.V1.Api.Presentations
  alias GoogleApi.Slides.V1.Model.Page

  alias Platform.Core.Schema.Slide

  def get_presentation!(presentation_id) when is_binary(presentation_id) do
    connection = get_google_slides_connection!()

    {:ok, presentation} = Presentations.slides_presentations_get(connection, presentation_id, fields: "presentationId,title,slides")
    presentation
  end

  def get_slide!(presentation_id, slide_id) do
    connection = get_google_slides_connection!()

    {:ok, slide_page} = Presentations.slides_presentations_pages_get(connection, presentation_id, slide_id)
    slide_page
  end

  def get_slide_thumb!(presentation_id, slide_id) do
    connection = get_google_slides_connection!()

    {:ok, slide_page_thumb} = Presentations.slides_presentations_pages_get_thumbnail(connection, presentation_id, slide_id)
    slide_page_thumb
  end

  def download_slide_thumb!(presentation_id, slide_id, filename) do
    slide_page_thumb = get_slide_thumb!(presentation_id, slide_id)
    url = slide_page_thumb.contentUrl

    # get directory out of the filename
    [_, directory] = Regex.run(~r/([\s\S]*\/)[\s\S]*?/, filename)
    File.mkdir_p(directory)

    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    File.write!(filename, body)

    filename
  end

  # Private functions

  defp get_google_slides_connection! do
    scopes = [
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.readonly",
      "https://www.googleapis.com/auth/presentations",
      "https://www.googleapis.com/auth/presentations.readonly"
    ]

    {:ok, goth_token} = Token.for_scope(Enum.join(scopes, " "))

    GoogleApi.Slides.V1.Connection.new(goth_token.token)
  end

  def sha256(data), do: :crypto.hash(:sha256, data)

  @doc """
  Generates a hash for Speakernotes

  Generate Hash from the speaker notes
  iex> generate_hash_for_speakernotes(%Page{slideProperties: %{notesPage: %{"text": "ABC123"}}})
  "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90"

  Other data as speakernotes don't influence this hash
  iex> generate_hash_for_speakernotes(%Page{objectId: "someOtherData", slideProperties: %{notesPage: %{"text": "ABC123"}}})
  "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90"

  If you change the speakernotes, the hash changes too
  iex> generate_hash_for_speakernotes(%Page{slideProperties: %{notesPage: %{"text": "321ABC"}}})
  "AA9C63E9DEFD30BD013470F152F45602FB2621AA28CE408F77323F7240665FE1"

  """
  def generate_hash_for_speakernotes(%Page{slideProperties: %{notesPage: notesPage}}) do
    notesPage
    |> Poison.encode!()
    |> sha256()
    |> Base.encode16()
  end

  @doc """
  Generates a hash for pageElements of a Slide

  Generate a hash for a page
  iex> generate_hash_for_page_elements(%Page{pageElements: [%PageElement{description: "A"}] })
  "A964EE70387C0A9532D3C81B2754FB0D62ECFCFAC8D2EC5119760AC5593C3464"

  If you change something in this page, the hash changes
  iex> generate_hash_for_page_elements(%Page{pageElements: [%PageElement{description: "B"}] })
  "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"

  If you change something else e.g. the speaker notes the hash stay constant for this slide
  iex> generate_hash_for_page_elements(%Page{pageElements: [%PageElement{description: "B"}], slideProperties: %{notesPage: %{"text": "321ABC"}}})
  "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"

  """
  def generate_hash_for_page_elements(%Page{pageElements: page_elements}) do
    page_elements
    |> Poison.encode!
    |> sha256()
    |> Base.encode16()
  end

  @doc """
  Get speaker notes for a page object

  iex> gslides = get_base_slide(object_id: "objID_1", content: "Example Content 1", speaker_notes: "Speaker Notes 1")
  iex> get_speaker_notes(gslides)
  "Speaker Notes 1"

  iex> notes = ["Speaker Notes 1!!", "Speaker Notes 2!!"]
  iex> gslides = get_base_slide(object_id: "objID_1", content: "Example Content 1", speaker_notes: notes )
  iex> get_speaker_notes(gslides)
  "Speaker Notes 1!!Speaker Notes 2!!"

  """
  def get_speaker_notes(%Page{slideProperties: %{notesPage: notesPage}}) do
    notes_object_id = notesPage.notesProperties.speakerNotesObjectId

    notes_root_element =
      notesPage.pageElements
      |> Enum.find(fn(e) -> e.objectId == notes_object_id end)

    if notes_root_element.shape.text do
      text_elements =
        notes_root_element.shape.text.textElements
        |> Enum.map(fn(e) ->
          if e.textRun != nil do
            e.textRun.content
          end
        end)

        Enum.join(text_elements)
    else
      ""
    end
  end

  @doc """

  iex> any_content_changed?(%{speaker_notes_hash: "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90", page_elements_hash: "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"}, %Page{slideProperties: %{notesPage: %{"text": "ABC123"}}, pageElements: [%PageElement{description: "B"}]})
  false

  iex> any_content_changed?(%{speaker_notes_hash: "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90", page_elements_hash: "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"}, %Page{slideProperties: %{notesPage: %{"text": "ABC1234"}}, pageElements: [%PageElement{description: "B"}]})
  true

  iex> any_content_changed?(%{speaker_notes_hash: "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90", page_elements_hash: "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"}, %Page{slideProperties: %{notesPage: %{"text": "ABC123"}}, pageElements: [%PageElement{description: "C"}]})
  true

  """
  def any_content_changed?(slide, google_slide) do
    content_changed_for_speaker_notes?(slide, google_slide) || content_changed_for_page_elements?(slide, google_slide)
  end

  @doc """

  iex> content_changed_for_speaker_notes?(%{speaker_notes_hash: "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90"}, %Page{slideProperties: %{notesPage: %{"text": "ABC123"}}})
  false

  iex> content_changed_for_speaker_notes?(%{speaker_notes_hash: "0D7FDBE1B2533EC8A3E2911E625CDEFF803669076F992D88B3E3BA094F859B90"}, %Page{slideProperties: %{notesPage: %{"text": "ABC123!!"}}})
  true

  """
  def content_changed_for_speaker_notes?(%{speaker_notes_hash: old_hash}, %Page{} = google_slide) do
    new_hash = generate_hash_for_speakernotes(google_slide)

    new_hash != old_hash
  end

  @doc """

  iex> content_changed_for_page_elements?(%{page_elements_hash: "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"}, %Page{pageElements: [%PageElement{description: "B"}] })
  false

  iex> content_changed_for_page_elements?(%{page_elements_hash: "0C8D2536C31320F54769B3D9AF7429E5E8157B79D6C4C1EEB193812D981643FD"}, %Page{pageElements: [%PageElement{description: "C"}] })
  true

  """
  def content_changed_for_page_elements?(%{page_elements_hash: old_hash}, %Page{} = google_slide) do
    new_hash = generate_hash_for_page_elements(google_slide)

    new_hash != old_hash
  end


  def get_title(%Page{pageElements: nil}), do: "NO TITLE"
  def get_title(%Page{pageElements: pageElements}) do
    page =
      pageElements
      |> Enum.find(&contains_element_title?(&1))

    get_text_from_page(page)
  end

  def get_text_from_page(%{shape: %{text: %{textElements: elements}}}) do
    text_element =
    elements
    |> Enum.find(fn(e) -> e.textRun != nil end)

    text_element.textRun.content
  end
  def get_text_from_page(_), do: "NO TITLE"

  @doc """
  Check of there a the correct element for the title

  iex> contains_element_title?(nil)
  false

  iex> example_element = %{}
  iex> contains_element_title?(example_element)
  false

  iex> example_element = %{shape: %{placeholder: %{type: "TITLE"}}}
  iex> contains_element_title?(example_element)
  false

  iex> example_element = %{shape: %{placeholder: %{type: "TITLE"}, text: "Example Title"}}
  iex> contains_element_title?(example_element)
  true

  """
  def contains_element_title?(%{shape: %{placeholder: %{type: "TITLE"}, text: _}}), do: true
  def contains_element_title?(_), do: false

end
