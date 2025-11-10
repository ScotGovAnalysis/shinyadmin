#' Render quarto dashboard
#'
#' @param qmd_path Path to qmd script
#' @param output_path Path to desired output file destination
#'
#' @return `output_path` (invisibly).
#' @export

render_dashboard <- function(qmd_path, output_path) {

  if (tools::file_ext(qmd_path) != "qmd") {
    cli::cli_abort(
      paste("{.arg qmd_path} must be a `qmd` file",
            "(not `{tools::file_ext(qmd_path)}`).")
    )
  }

  if (tools::file_ext(output_path) != "html") {
    cli::cli_abort(
      paste("{.arg output_path} must be an `html` file",
            "(not `{tools::file_ext(output_path)}`).")
    )
  }

  quarto::quarto_render(qmd_path)

  out <- gsub("\\.qmd", "\\.html", qmd_path)

  x <- file.rename(out, output_path)

  if (x) {
    invisible(output_path)
  } else {
    cli::cli_abort(c(
      "x" = "Output file not saved to {.path {output_path}}.",
      "i" = "Check file at {.path {out}}."
    ))
  }

}
