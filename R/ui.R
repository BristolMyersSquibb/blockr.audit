audit_ext_ui <- function(id, board) {
  ns <- NS(id)

  tagList(
    tags$div(
      class = "audit-container",
      style = "height: 100vh; display: flex; flex-direction: column;",
      tags$div(
        class = "audit-toolbar",
        style = paste0(
          "padding: 8px 12px; border-bottom: 1px solid #e5e7eb; ",
          "display: flex; align-items: center; gap: 8px; ",
          "background: #f9fafb;"
        ),
        tags$span(
          style = "font-weight: 600; font-size: 14px; color: #374151;",
          "Audit Trail"
        ),
        tags$span(
          id = ns("entry-count"),
          class = "audit-badge",
          style = paste0(
            "background: #e5e7eb; color: #6b7280; font-size: 11px; ",
            "padding: 2px 8px; border-radius: 10px;"
          ),
          "0 entries"
        ),
        tags$div(style = "flex: 1;"),
        tags$select(
          id = ns("filter_event"),
          class = "audit-filter",
          style = paste0(
            "font-size: 12px; padding: 4px 8px; border: 1px solid #d1d5db; ",
            "border-radius: 4px; background: white;"
          ),
          tags$option(value = "all", "All events"),
          tags$option(value = "block_add", "Block added"),
          tags$option(value = "block_remove", "Block removed"),
          tags$option(value = "link_add", "Link added"),
          tags$option(value = "link_remove", "Link removed"),
          tags$option(value = "stack_add", "Stack added"),
          tags$option(value = "stack_remove", "Stack removed"),
          tags$option(value = "param_change", "Param changed"),
          tags$option(value = "block_error", "Block error"),
          tags$option(value = "block_success", "Block success")
        ),
        if (getOption("blockr.allow_clear_audit", FALSE)) {
          actionButton(
            ns("clear_log"),
            "Clear",
            class = "btn-sm",
            style = paste0(
              "font-size: 12px; padding: 4px 12px; background: white; ",
              "border: 1px solid #d1d5db; border-radius: 4px; color: #374151;"
            )
          )
        },
        downloadButton(
          ns("export_log"),
          "Export",
          class = "btn-sm",
          style = paste0(
            "font-size: 12px; padding: 4px 12px; background: white; ",
            "border: 1px solid #d1d5db; border-radius: 4px; color: #374151;"
          )
        )
      ),
      tags$div(
        class = "audit-log-table",
        style = "flex: 1; overflow-y: auto; padding: 0;",
        tableOutput(ns("log_table"))
      )
    ),
    htmltools::htmlDependency(
      name = "audit-ext",
      version = pkg_version(),
      src = c(file = "assets"),
      script = file.path("js", "audit.js"),
      stylesheet = file.path("css", "audit.css"),
      package = pkg_name()
    )
  )
}
