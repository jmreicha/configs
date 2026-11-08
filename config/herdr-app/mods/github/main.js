import { View } from "gpui-kit";
import { props } from "herdr";
import { Panel } from "./panel.js";
import { CiBadge } from "./ci.js";

// One mod, two views, so both share checks.js: the panel, or { view: "ci" } for the status-bar badge.
export default class GitHub extends View {
  init(_props, cx) {
    this.view = props()?.view === "ci" ? new CiBadge() : new Panel();
    this.view.init(props(), cx);
  }

  render(cx) {
    return this.view.render(cx);
  }
}
