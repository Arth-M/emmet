import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("turbo:frame-render", this.clearAll.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:frame-render", this.clearAll.bind(this))
  }

  clearAll() {
    document.getElementById("flash-messages").innerHTML = ""
    document.getElementById("flash-warning").innerHTML = ""
  }
}
