import jQuery from "jquery";
import CodeMirror from "codemirror";
import socket from "./socket";

// Now that you are connected, you can join channels with a topic:
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

jQuery(document).ready(function () {
  let elem = document.getElementById('slide_speaker_notes');

  let editor = CodeMirror.fromTextArea(elem, {
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
      slideChannel.push('speech', {language_key: 'en-US', voice_gender: 'female', text: text})
    },
    "Shift-Cmd-Enter": function (cm) {
      let text = getTextFromCurrentWordTillEnd(editor);
      console.log(text);
      slideChannel.push('speech', {language_key: 'en-US', voice_gender: 'female', text: text})
    }
  }
  editor.addKeyMap(map);
});
