import jQuery from "jquery";
import CodeMirror from "codemirror";

jQuery(document).ready(function () {
  let elem = document.getElementById('slide_speaker_notes');

  CodeMirror.fromTextArea(elem, {
    // mode: "markdown",
    theme: "default",
    lineNumbers: false,
    lineWrapping: true,
    tabSize: 2,
    tabMode: "indent",
    viewportMargin: Infinity,
  });
});
