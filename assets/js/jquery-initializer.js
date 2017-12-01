// This exposes jQuery to the global context.
// Used for bootstrap. Please don't add $ here.
// Use `import $ from "jquery";`
import jQuery from "jquery";
import Popper from "popper.js";

window.jQuery = jQuery;
window.$ = jQuery;
window.Popper = Popper;
