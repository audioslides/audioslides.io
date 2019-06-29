import jQuery from "jquery";
import CodeMirror from "codemirror";
import "codemirror/mode/xml/xml";
import socket from "./socket";

function getTextFromCurrentWordTillEnd(editor) {
  let lastLine = editor.lastLine()
  let lastChar = editor.getLine(lastLine).length
  let currentWord = editor.findWordAt(editor.getCursor());

  return editor.getRange(currentWord.anchor, {line: lastLine, ch: lastChar})
}

function getTextFromCurrentWordTillEndOfSentence(editor) {
  let text = getTextFromCurrentWordTillEnd(editor)
  return text.split(".")[0];
}

function createCodeMirrorEditor(elem) {
  let editor = CodeMirror.fromTextArea(elem, {
    mode: "text/html",
    theme: "default",
    lineNumbers: false,
    lineWrapping: true,
    tabSize: 2,
    tabMode: "indent",
    viewportMargin: Infinity,
  });

  var map = {
    "Cmd-Enter": function (cm) {
      let text = getTextFromCurrentWordTillEndOfSentence(editor);
      console.log(text);
      slideChannel.push('speech', {language_key: 'en-GB', voice_gender: 'male', text: text})
    },
    "Shift-Cmd-Enter": function (cm) {
      let text = getTextFromCurrentWordTillEnd(editor);
      console.log(text);
      slideChannel.push('speech', {language_key: 'en-GB', voice_gender: 'male', text: text})
    }
  }
  editor.addKeyMap(map);

  let slideChannel = socket.channel("slide", {})
  slideChannel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  slideChannel.on("speech", function (obj) {
    console.log(obj);
    let audio_elem = document.getElementById("speaker_preview")
    audio_elem.src = obj.preview_url
    audio_elem.pause();
    audio_elem.load(); //suspends and restores all audio element
    audio_elem.play();
  })

  jQuery("[data-editor-insert]").on("click", (event) => {
    event.preventDefault();
    let text = jQuery(event.target).data("editorInsert")
    let selection = editor.getSelection();

    if (selection.length > 0) {
      editor.replaceSelection(text.replace("$1", selection));
    } else {
      let doc = editor.getDoc();
      let cursor = doc.getCursor();
      doc.replaceRange(text.replace("$1", ""), cursor);
    }
  });
}

jQuery(document).ready(() => {
  let elem = document.getElementById('slide_speaker_notes');

  if (elem) {
    createCodeMirrorEditor(elem)
  }
});
