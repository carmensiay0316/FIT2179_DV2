vegaEmbed("#bar_country_2025","vega/bar_country_2025.json",
  {actions: false})
.then(function(result) {
  result.view.addEventListener("click", function(event, item) {
    if (item && item.datum && item.datum.country_name) {
      result.view
        .signal("selected_country", item.datum.country_name)
        .runAsync();
    }
  });
})
.catch(console.error);

vegaEmbed("#map_state_2025","vega/map_state_2025.json",{actions: false})
.then(function(result) {
  result.view.addEventListener("click", function(event, item) {
    if (item && item.datum && item.datum.state_abbr) {
      result.view
        .signal("selected_state", item.datum.state_abbr)
        .runAsync();
    }
  });
  result.view.addEventListener("dblclick", function(event, item) {
    result.view
      .signal("selected_state", "")
      .runAsync();
  });
}).catch(console.error);

vegaEmbed("#linked_state_country_lollipop", "vega/linked_state_country_lollipop.json", {actions: false})
  .catch(console.error);

vegaEmbed("#sector_area_2019_2025", "vega/sector_area_2019to2025.json", { actions: false })
  .catch(console.error);

vegaEmbed("#sector_bump_2019_2025", "vega/sector_bump_2019to2025.json", { actions: false })
  .catch(console.error);

vegaEmbed("#source_region_waffle_2025", "vega/source_region_waffle_2025.json", { actions: false })
  .catch(console.error);

vegaEmbed("#state_income_indexed_line", "vega/state_income_indexed_line.json", {
  actions: false})
  .catch(console.error);

vegaEmbed("#sector_income_heatmap", "vega/sector_income_heatmap.json", {
  actions: false})
  .catch(console.error);

vegaEmbed("#student_net_migration_gap_map", "vega/student_net_migration_map.json", {
  actions: false})
  .catch(console.error);