/* Use in your app by simply adding to your app's index.js:

import ToottownComment from "toottown"
*/

class ToottownComment extends HTMLElement {
  // Declarative Shadow DOM Fallback
  connectedCallback() {
    const tmpl = this.querySelector("template[shadowrootmode]")
    if (tmpl) {
      this.attachShadow({ mode: tmpl.getAttribute("shadowrootmode") })
      this.shadowRoot.replaceChildren(tmpl.content.cloneNode(true))
      tmpl.remove()
    }
  }
}

if (!customElements.get("toottown-comment")) {
  customElements.define("toottown-comment", ToottownComment)
}

export default ToottownComment
