import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pav"
export default class extends Controller {
  // connect() {
  // }
   static values = { id: Number, lat: Number, lng: Number }

  select() {
    // 1. Recentrer la carte
    window.pavMap.flyTo([this.latValue, this.lngValue], 15)

    // 2. Charger les données du PAV
    fetch(`/home/pav/${this.idValue}`)
      .then(r => r.json())
      .then(({ fill_history, incidents }) => {
        renderFillChart(fill_history)   // chart.js / recharts
        renderIncidentList(incidents)
      })
  }
}
