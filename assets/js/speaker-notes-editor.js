import jQuery from "jquery";
import CodeMirror from "codemirror";

function getTextFromCurrentWordTillEnd(editor) {
  let currentLine = editor.getCursor().line;
  let currentChar = editor.getCursor().ch;

  let lastLine = editor.lastLine()
  let lastChar = editor.getLine(lastLine).length

  let wordChar = editor.findWordAt({line: currentLine, ch: currentChar}).anchor.ch;

  return editor.getRange({line: currentLine, ch: wordChar}, {line: lastLine, ch: lastChar})
}

jQuery(document).ready(function () {
  let elem = document.getElementById('slide_speaker_notes');

  let editor = CodeMirror.fromTextArea(elem, {
    // mode: "markdown",
    theme: "default",
    lineNumbers: false,
    lineWrapping: true,
    tabSize: 2,
    tabMode: "indent",
    viewportMargin: Infinity,
  });

  editor.on('cursorActivity', function () {
    let text = getTextFromCurrentWordTillEnd(editor);
    console.log(text);
  });


});
