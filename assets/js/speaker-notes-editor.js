import jQuery from "jquery";
import CodeMirror from "codemirror";

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
    },
    "Shift-Cmd-Enter": function (cm) {
      let text = getTextFromCurrentWordTillEnd(editor);
      console.log(text);
    }
  }
  editor.addKeyMap(map);
});
