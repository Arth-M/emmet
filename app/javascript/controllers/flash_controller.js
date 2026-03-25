import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // on each turbo-frame load clear innerHTML of messages displayed to user
  connect() {
    document.addEventListener("turbo:frame-load", this.clearAll.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.clearAll.bind(this))
  }

  clearAll() {
    document.getElementById("flash-message").innerHTML = ""
  }
}
