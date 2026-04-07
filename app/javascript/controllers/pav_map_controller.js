// app/javascript/controllers/pav_map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "fillChart", "chartPlaceholder", "pavIncidents"]
  static values  = { locations: Array }

  connect() {
    this.chart      = null
    this.activeItem = null
    this.initMap()
    console.log("pav map controller is in tha place")
  }

  disconnect() {
    if (this.map)  this.map.remove()
    if (this.chart) this.chart.destroy()
  }


// ── Map ────────────────────────────────────────────────────────────────────
initMap() {
  this.map = L.map(this.mapTarget, { zoomControl: false }).setView([48.8566, 2.3522], 12)
  L.control.zoom({ position: "bottomright" }).addTo(this.map)
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "© OpenStreetMap", maxZoom: 19
  }).addTo(this.map)

  // Stocker les markers par location id pour pouvoir les filtrer
  this.markers = {}

  this.locationsValue.forEach(loc => {
    const marker = L.marker([loc.lat, loc.lng], { icon: this.makeIcon(loc) }).addTo(this.map)
    marker.bindPopup(this.popupHtml(loc))
    marker.on("click", () => {
      this.map.flyTo([loc.lat, loc.lng], 15, { duration: 0.8 })
      this.setActiveItem(loc.id)
      this.fetchPav(loc.id, loc.name)
    })
    this.markers[loc.id] = { marker, waste_type: loc.waste_type }
  })
}

makeIcon(loc) {
    const color = loc.fill_percent > 85 ? "#f43f5e" : loc.fill_percent > 70 ? "#f59e0b" : "#10b981"
    const inner = loc.open_incident
      ? `<text x="16" y="20" text-anchor="middle" font-size="11" fill="#f59e0b">!</text>`
      : `<text x="16" y="20" text-anchor="middle" font-size="8" fill="#fff" font-family="monospace">${loc.fill_percent}</text>`

    return L.divIcon({
      html: `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="38" viewBox="0 0 32 38">
               <path d="M16 0C7.163 0 0 7.163 0 16c0 10 16 22 16 22S32 26 32 16C32 7.163 24.837 0 16 0z" fill="${color}" opacity=".9"/>
               <circle cx="16" cy="16" r="7" fill="#0f172a" opacity=".75"/>
               ${inner}
             </svg>`,
      className: "",
      iconSize: [32, 38],
      iconAnchor: [16, 38],
      popupAnchor: [0, -40]
    })
  }

filterByWasteType(event) {
  const btn = event.currentTarget
  const wasteType = btn.dataset.wasteType

    // Mettre à jour les boutons actifs
    document.querySelectorAll("[data-waste-type]").forEach(b => b.dataset.active = "false")
    btn.dataset.active = "true"

    // Afficher/masquer les markers
    Object.values(this.markers).forEach(({ marker, waste_type }) => {
      if (wasteType === "all" || waste_type === wasteType) {
        marker.addTo(this.map)
      } else {
        marker.remove()
      }
    })
  }

  // ── Appelé par data-action="click->pav-map#selectPav" sur chaque <li> ──────
  selectPav(event) {
    const item = event.currentTarget
    const id   = item.dataset.pavId
    const lat  = parseFloat(item.dataset.pavLat)
    const lng  = parseFloat(item.dataset.pavLng)
    const name = item.dataset.pavName

    this.map.flyTo([lat, lng], 15, { duration: 0.8 })
    this.setActiveItem(id)
    this.fetchPav(id, name)
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  fetchPav(id, name) {
    fetch(`/home/pav/${id}`)
      .then(r => r.json())
      .then(({ fill_history, incidents }) => {
      // console.log("fill_history", fill_history)
      // console.log("incidents", incidents)
      // console.log("fillChartTarget", this.fillChartTarget)
      // console.log("pavIncidentsTarget", this.pavIncidentsTarget)
        this.renderChart(fill_history, name)
        this.renderIncidents(incidents)
      })
  }

  popupHtml(loc) {
    const color = loc.fill_percent > 85 ? "#f43f5e" : loc.fill_percent > 50 ? "#f59e0b" : "#10b981"

    return `<strong>${loc.name}</strong><br>
           ${loc.waste_type}<br>
            Fill : <strong style="color:${color}">${loc.fill_percent}%</strong>
            ${loc.open_incident ? "<br>⚠ Incident ouvert" : ""}`
  }





  // ── Sidebar active state ───────────────────────────────────────────────────
  setActiveItem(id) {
    if (this.activeItem) {
      this.activeItem.dataset.active = "false"
    }
    const item = document.getElementById(`pav-item-${id}`)
    if (item) {
      item.dataset.active = "true"
      item.scrollIntoView({ behavior: "smooth", block: "nearest" })
      this.activeItem = item
    }
  }

  // ── Chart ──────────────────────────────────────────────────────────────────
  renderChart(data, name) {

    if (!data?.length) {
      this.fillChartTarget.classList.add("hidden")
      this.chartPlaceholderTarget.classList.remove("hidden")
      this.chartPlaceholderTarget.textContent = "Pas de données de remplissage."
      return
    }

    this.chartPlaceholderTarget.classList.add("hidden")
    this.fillChartTarget.classList.remove("hidden")

    if (this.chart) this.chart.destroy()

    const ctx      = this.fillChartTarget.getContext("2d")
    const gradient = ctx.createLinearGradient(0, 0, 0, 180)
    gradient.addColorStop(0, "rgba(56,189,248,.3)")
    gradient.addColorStop(1, "rgba(56,189,248,.02)")

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: data.map(d => new Date(d.occurred_at).toLocaleDateString("fr-FR", {
          day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit"
        })),
        datasets: [{
          data: data.map(d => d.fill_percent),
          borderColor: "#38bdf8",
          backgroundColor: gradient,
          borderWidth: 2,
          pointRadius: 3,
          pointBackgroundColor: "#38bdf8",
          tension: .35,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: "#1e293b", borderColor: "#334155", borderWidth: 1,
            titleColor: "#e2e8f0", bodyColor: "#64748b",
            callbacks: { label: ctx => ` ${ctx.parsed.y}%` }
          }
        },
        scales: {
          x: { ticks: { color: "#475569", font: { size: 10 }, maxTicksLimit: 7 }, grid: { color: "#1e293b" } },
          y: { min: 0, max: 100, ticks: { color: "#475569", font: { size: 10 }, callback: v => v + "%" }, grid: { color: "#1e293b" } }
        }
      }
    })
  }

  // ── PAV incidents ──────────────────────────────────────────────────────────
  renderIncidents(incidents) {
    const el = this.pavIncidentsTarget
    el.classList.remove("flex")
    console.log("Hello",incidents)

    if (!incidents?.length) {
      el.innerHTML = `<p class="text-sm text-center py-8">Aucun incident pour ce PAV.</p>`
      return
    }

    el.innerHTML = incidents.map(inc => {
      const occurredAt = new Date(inc.occurred)
      const date = occurredAt.toLocaleDateString("fr-FR", { day: "2-digit", month: "2-digit" })
      const delayLabel = inc.days_since === 0 ? "Aujourd'hui" : `${inc.days_since} jours`

      return `
        <div class="border-l-2 border-l-amber-500/50 border-b border-slate-800/60 px-4 py-3">
          <div class="flex items-center justify-between gap-2 mb-1.5">
            <p class="card px-1.5 py-0.5 text-xs">${inc.type}</p>
            <p class="text-xs">Depuis le ${date}</p>
            <p class="text-xs">Délai : ${delayLabel}</p>
          </div>
        </div>`
    }).join("")
  }
}
