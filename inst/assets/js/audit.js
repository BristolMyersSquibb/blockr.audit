Shiny.addCustomMessageHandler("audit-update-badge", function(message) {
  var el = document.getElementById(message.id);
  if (el) {
    el.textContent = message.label;
  }
});
