
<!-- README.md is generated from README.Rmd. Please edit that file -->

# blockr.audit

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of blockr.audit is to provide an audit trail extension for
`blockr.core`. It records board operations (block additions/removals,
link changes, parameter updates, errors) with timestamps and provenance
metadata. The trail can be viewed as a log table, exported for
compliance reporting, and optionally restored across sessions.

## Installation

You can install the development version of blockr.audit like so:

``` r
pak::pak("BristolMyersSquibb/blockr.audit")
```

## Basic example

To start up a basic board with audit trail:

``` r
library(blockr.audit)
library(blockr.core)
library(blockr.dock)
library(blockr.dag)

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
```

<figure>
<img src="man/figures/basic-app.png" alt="blockr.audit basic app" />
<figcaption aria-hidden="true">blockr.audit basic app</figcaption>
</figure>

## Restoring a previous audit log

You can restore an audit log from a previous session:

``` r
library(blockr.audit)
library(blockr.core)
library(blockr.dock)

# Demonstrates restoring an audit log from a previous session
previous_log <- new_audit_log(list(
  new_audit_entry(
    event = "block_add",
    block_id = "a",
    details = list(class = "dataset_block"),
    timestamp = "2026-03-01 10:00:00"
  ),
  new_audit_entry(
    event = "block_add",
    block_id = "b",
    details = list(class = "scatter_block"),
    timestamp = "2026-03-01 10:00:05"
  ),
  new_audit_entry(
    event = "link_add",
    details = list(from = "a", to = "b", input = "data"),
    timestamp = "2026-03-01 10:00:10"
  )
))

serve(
  new_dock_board(
    blocks = c(
      a = new_dataset_block("iris"),
      b = new_scatter_block(x = "Sepal.Length", y = "Sepal.Width")
    ),
    links = list(from = "a", to = "b", input = "data"),
    extensions = new_audit_extension(log = previous_log)
  )
)
```

<figure>
<img src="man/figures/restore-app.png" alt="blockr.audit restore app" />
<figcaption aria-hidden="true">blockr.audit restore app</figcaption>
</figure>
