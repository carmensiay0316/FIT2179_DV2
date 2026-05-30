vegaEmbed("#bar_country_2025", "vega/bar_country_2025.json", { actions: false })
  .then(function(result) {
    result.view.addEventListener("click", function(event, item) {
      if (item && item.datum && item.datum.country_name) {
        result.view
          .signal("selected_country", item.datum.country_name)
          .runAsync();
      }
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_country", "")
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#map_state_2025", "vega/map_state_2025.json", { actions: false })
  .then(function(result) {
    result.view.addEventListener("click", function(event, item) {
      if (item && item.datum && item.datum.state_abbr) {
        result.view
          .signal("selected_state", item.datum.state_abbr)
          .runAsync();
      }
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_state", "")
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#linked_state_country_lollipop", "vega/linked_state_country_lollipop.json", { actions: false })
  .then(function(result) {
    result.view.addEventListener("click", function(event, item) {
      if (item && item.datum && item.datum.nationality) {
        result.view
          .signal("selected_lollipop_country", item.datum.nationality)
          .runAsync();
      }
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_lollipop_country", "")
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#sector_area_2019_2025", "vega/sector_area_2019to2025.json", { actions: false })
  .then(function(result) {
    function updateSectorAnnotation(item) {
      if (item && item.datum && item.datum.sector_label && item.datum.year) {
        result.view
          .signal("selected_sector_area", item.datum.sector_label)
          .signal("selected_year_area", Number(item.datum.year))
          .runAsync();
      }
    }

    result.view.addEventListener("click", function(event, item) {
      updateSectorAnnotation(item);
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_sector_area", "")
        .signal("selected_year_area", 0)
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#sector_bump_2019_2025", "vega/sector_bump_2019to2025.json", { actions: false })
  .then(function(result) {
    function updateBumpAnnotation(item) {
      if (item && item.datum && item.datum.sector_label && item.datum.year) {
        result.view
          .signal("selected_bump_sector", item.datum.sector_label)
          .signal("selected_bump_year", item.datum.year)
          .runAsync();
      }
    }

    result.view.addEventListener("click", function(event, item) {
      updateBumpAnnotation(item);
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_bump_sector", "")
        .signal("selected_bump_year", 0)
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#source_region_waffle_2025", "vega/source_region_waffle_2025.json", { actions: false })
  .then(function(result) {
    function updateWaffleAnnotation(item) {
      if (item && item.datum && item.datum.region) {
        result.view
          .signal("selected_waffle_region", item.datum.region)
          .runAsync();
      }
    }

    result.view.addEventListener("click", function(event, item) {
      updateWaffleAnnotation(item);
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_waffle_region", "")
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#state_income_indexed_line", "vega/state_income_indexed_line.json", {
  actions: false
})
  .then(function(result) {
    function updateIncomeAnnotation(item) {
      if (item && item.datum && item.datum.state_name_full && item.datum.financial_year) {
        result.view
          .signal("selected_income_state", item.datum.state_name_full)
          .signal("selected_income_year", item.datum.financial_year)
          .runAsync();
      }
    }

    result.view.addEventListener("click", function(event, item) {
      updateIncomeAnnotation(item);
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_income_state", "")
        .signal("selected_income_year", "")
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#sector_income_heatmap", "vega/sector_income_heatmap.json", {
  actions: false
})
  .then(function(result) {
    function updateHeatmapAnnotation(item) {
      if (item && item.datum && item.datum.sector_label && item.datum.financial_year) {
        result.view
          .signal("selected_heatmap_sector", item.datum.sector_label)
          .signal("selected_heatmap_year", item.datum.financial_year)
          .runAsync();
      }
    }

    result.view.addEventListener("click", function(event, item) {
      updateHeatmapAnnotation(item);
    });

    result.view.addEventListener("dblclick", function() {
      result.view
        .signal("selected_heatmap_sector", "")
        .signal("selected_heatmap_year", "")
        .runAsync();
    });
  })
  .catch(console.error);

vegaEmbed("#student_net_migration_gap_map", "vega/student_net_migration_map.json", {
  actions: false
})
  .then(function(result) {
    const panel = document.getElementById("migration_annotation_panel");

    function formatNumber(value) {
      const num = Number(String(value).replace(/,/g, ""));
      if (Number.isNaN(num)) {
        return value;
      }
      return num.toLocaleString("en-AU");
    }

    function formatSignedNumber(value) {
      const num = Number(String(value).replace(/,/g, ""));
      if (Number.isNaN(num)) {
        return value;
      }
      return (num > 0 ? "+" : "") + num.toLocaleString("en-AU");
    }

    function balanceText(value) {
      const num = Number(String(value).replace(/,/g, ""));
      if (num > 0) {
        return "Net student gain";
      }
      if (num < 0) {
        return "Net student loss";
      }
      return "Balanced flow";
    }

    function resetMigrationPanel() {
      panel.innerHTML = `
        <h4>Selected state details</h4>
        <p>Click a state on the map to show migration details.</p>
      `;
    }

    function updateMigrationAnnotation(item) {
      if (!item || !item.datum || !item.datum.state_name) {
        return;
      }

      const d = item.datum;

      panel.innerHTML = `
        <h4>Selected state details</h4>

        <p><strong>State:</strong><br>${d.state_name}</p>
        <p><strong>Financial year:</strong> ${d.financial_year}</p>
        <p><strong>Student arrivals:</strong> ${formatNumber(d.student_arrivals)}</p>
        <p><strong>Student departures:</strong> ${formatNumber(d.student_departures)}</p>
        <p><strong>Net migration:</strong> ${formatSignedNumber(d.net_student_migration)}</p>
        <p><strong>Balance:</strong> ${balanceText(d.net_student_migration)}</p>
      `;
    }

    result.view.addEventListener("click", function(event, item) {
      updateMigrationAnnotation(item);
    });

    result.view.addEventListener("dblclick", function() {
      resetMigrationPanel();
    });
  })
  .catch(console.error);