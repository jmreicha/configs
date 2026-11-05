import { View } from "gpui-kit";
import { Panel } from "./panel.js";

export default class Jira extends View {
  init(props, cx) {
    this.panel = new Panel();
    this.panel.init(props, cx);
  }

  render(cx) {
    return this.panel.render(cx);
  }
}
