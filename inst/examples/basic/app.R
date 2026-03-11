library(blockr.audit)
library(blockr.core)
library(blockr.dock)
library(blockr.dag)

options(blockr.allow_clear_audit = TRUE)

serve(
  new_dock_board(
    blocks = c(
      a = new_dataset_block("iris"),
      b = new_scatter_block(x = "Sepal.Length", y = "Sepal.Width")
    ),
    links = list(from = "a", to = "b", input = "data"),
    stacks = c(
      stack_1 = new_dock_stack(c("a", "b"), color = "#0000FF")
    ),
    extensions = list(
      dag = new_dag_extension(),
      audit = new_audit_extension()
    ),
    layout = list("audit", "dag", list("a", "b"))
  )
)
