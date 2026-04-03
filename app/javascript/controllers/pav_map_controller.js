// app/javascript/controllers/pav_map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "fillChart", "chartPlaceholder", "chartTitle", "pavIncidents"]
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

  // ── Map ────────────────────────────────────────────────────────────────────
  initMap() {
    this.map = L.map(this.mapTarget, { zoomControl: false }).setView([48.8566, 2.3522], 12)

    L.control.zoom({ position: "bottomright" }).addTo(this.map)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap",
      maxZoom: 19
    }).addTo(this.map)

    this.locationsValue.forEach(loc => {
      const marker = L.marker([loc.lat, loc.lng], { icon: this.makeIcon(loc) }).addTo(this.map)
      marker.bindPopup(this.popupHtml(loc))
      marker.on("click", () => {
        this.map.flyTo([loc.lat, loc.lng], 15, { duration: 0.8 })
        this.setActiveItem(loc.id)
        this.fetchPav(loc.id, loc.name)

      })
    })
  }

  makeIcon(loc) {
    const color = loc.fill_percent > 85 ? "#f43f5e" : loc.fill_percent > 50 ? "#f59e0b" : "#10b981"
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

  popupHtml(loc) {
    const color = loc.fill_percent > 85 ? "#f43f5e" : loc.fill_percent > 50 ? "#f59e0b" : "#10b981"
    return `<strong>${loc.name}</strong><br>
            Fill : <strong style="color:${color}">${loc.fill_percent}%</strong>
            ${loc.open_incident ? "<br>⚠ Incident ouvert" : ""}`
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
    this.chartTitleTarget.textContent = name || "—"

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

    if (!incidents?.length) {
      el.innerHTML = `<p class="text-slate-600 text-sm text-center py-8">Aucun incident pour ce PAV.</p>`
      return
    }

    el.innerHTML = incidents.filter(inc => !inc.resolved).map(inc => {
      const date  = new Date(inc.occurred).toLocaleDateString("fr-FR", {
        day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit"
      })
      const delay = inc.delay_h ? `${inc.delay_h.toFixed(1)}h` : "—"
      const statusClass = inc.resolved ? "text-emerald-400" : "text-amber-400"
      const dotClass    = inc.resolved ? "bg-emerald-400" : "bg-amber-400 animate-pulse"
      const label       = inc.resolved ? "Résolu" : "Ouvert"
      const borderLeft  = inc.resolved ? "" : "border-l-2 border-l-amber-500/50"

      return `
        <div class="border-b border-slate-800/60 px-4 py-3 hover:bg-slate-800/40 transition-colors ${borderLeft}">
          <div class="flex items-center justify-between gap-2 mb-1.5">
            <span class="bg-slate-800 border border-slate-700/80 text-slate-300 rounded px-1.5 py-0.5 text-[10px]">${inc.type}</span>
            <span class="inline-flex items-center gap-1.5 text-xs ${statusClass}">
              <span class="w-1.5 h-1.5 rounded-full shrink-0 ${dotClass}"></span>${label}
            </span>
          </div>
          <div class="flex items-center justify-between text-[10px] text-slate-500">
            <span>${date}</span>
            <span>Délai : ${delay}</span>
          </div>
        </div>`
    }).join("")
  }
}
