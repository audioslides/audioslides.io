import jQuery from "jquery";
import CodeMirror from "codemirror";

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

  editor.on('cursorActivity', function(){
    var A1 = editor.getCursor().line;
    var A2 = editor.getCursor().ch;

    var lastLine = editor.lastLine()
    var lastChar = editor.getLine(lastLine).length

    var B1 = editor.findWordAt({line: A1, ch: A2}).anchor.ch;

    console.log(editor.getRange({line: A1,ch: B1}, {line: lastLine, ch: lastChar}));
  });
});
