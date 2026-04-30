#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
cran_mirror <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "https://cloud.r-project.org"
log_file <- if (length(args) >= 2 && nzchar(args[2])) args[2] else "AllPackageInstallationLogs/00_RPackageUpdate.log"

log_dir <- dirname(log_file)
if (!dir.exists(log_dir)) {
  dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
}

log_con <- file(log_file, open = "wt")
sink(log_con, split = TRUE)
sink(log_con, type = "message")

close_sinks <- function() {
  sink(type = "message")
  sink()
  close(log_con)
}
on.exit(close_sinks(), add = TRUE)

cat("R package update log\n")
cat("Timestamp: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n", sep = "")
cat("CRAN mirror: ", cran_mirror, "\n", sep = "")

options(repos = c(CRAN = cran_mirror))
all_repos <- BiocManager::repositories()
cat("Repositories: ", paste(names(all_repos), collapse = ", "), "\n\n", sep = "")

update_failed <- FALSE
update_error <- NULL

log_warning <- function(w) {
  cat("WARNING: ", conditionMessage(w), "\n", sep = "")
  invokeRestart("muffleWarning")
}

before <- installed.packages()[, c("Package", "Version"), drop = FALSE]
before_versions <- setNames(before[, "Version"], before[, "Package"])

outdated <- tryCatch(
  withCallingHandlers(
    old.packages(repos = all_repos, checkBuilt = TRUE),
    warning = log_warning
  ),
  error = function(e) {
    cat("ERROR while checking outdated packages: ", conditionMessage(e), "\n", sep = "")
    NULL
  }
)
if (is.null(outdated)) {
  cat("Unable to determine outdated packages before update.\n")
} else if (nrow(outdated) == 0) {
  cat("No outdated packages detected — all packages are up to date.\n")
} else {
  cat("Outdated packages detected: ", nrow(outdated), "\n", sep = "")
  outdated_tbl <- data.frame(
    Package = rownames(outdated),
    Installed = outdated[, "Installed"],
    Available = outdated[, "ReposVer"],
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  print(outdated_tbl)
}

pkg_updated   <- character()
pkg_failed    <- character()
pkg_unchanged <- character()

if (!is.null(outdated) && nrow(outdated) > 0) {
  n_pkgs <- nrow(outdated)
  cat("\nUpdating ", n_pkgs, " package(s)...\n", sep = "")
  for (i in seq_len(n_pkgs)) {
    pkg     <- rownames(outdated)[i]
    old_ver <- outdated[i, "Installed"]
    new_ver <- outdated[i, "ReposVer"]
    cat(sprintf("  [%d/%d] %s (%s -> %s)... ", i, n_pkgs, pkg, old_ver, new_ver))
    this_failed <- FALSE
    tryCatch(
      withCallingHandlers(
        install.packages(pkg, repos = all_repos, quiet = TRUE),
        warning = log_warning
      ),
      error = function(e) {
        this_failed <<- TRUE
        update_failed <<- TRUE
        update_error  <<- conditionMessage(e)
        cat("FAILED\n")
        cat("    ERROR: ", conditionMessage(e), "\n", sep = "")
      }
    )
    if (!this_failed) {
      current_ver <- tryCatch(
        as.character(packageVersion(pkg)),
        error = function(e) old_ver
      )
      if (current_ver != old_ver) {
        cat("updated\n")
        pkg_updated <- c(pkg_updated, pkg)
      } else {
        cat("unchanged\n")
        pkg_unchanged <- c(pkg_unchanged, pkg)
      }
    } else {
      pkg_failed <- c(pkg_failed, pkg)
    }
  }
} else {
  cat("\nNo packages to update.\n")
}

after <- installed.packages()[, c("Package", "Version"), drop = FALSE]
after_versions <- setNames(after[, "Version"], after[, "Package"])

new_pkgs     <- setdiff(names(after_versions), names(before_versions))
removed_pkgs <- setdiff(names(before_versions), names(after_versions))

cat("\nSummary of changes:\n")
if (length(pkg_updated) == 0 && length(pkg_failed) == 0 && length(new_pkgs) == 0 && length(removed_pkgs) == 0) {
  cat("No package version changes detected.\n")
} else {
  if (length(pkg_updated) > 0) {
    changed_tbl <- data.frame(
      Package  = pkg_updated,
      Previous = unname(before_versions[pkg_updated]),
      Current  = unname(after_versions[pkg_updated]),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
    cat("Updated packages (" , length(pkg_updated), "):\n", sep = "")
    print(changed_tbl)
  }

  if (length(pkg_failed) > 0) {
    cat("Failed packages (", length(pkg_failed), "):\n", sep = "")
    cat(paste0("  ", pkg_failed, collapse = "\n"), "\n", sep = "")
  }

  if (length(new_pkgs) > 0) {
    new_tbl <- data.frame(
      Package = new_pkgs,
      Current = unname(after_versions[new_pkgs]),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
    cat("Newly installed packages:\n")
    print(new_tbl)
  }

  if (length(removed_pkgs) > 0) {
    removed_tbl <- data.frame(
      Package  = removed_pkgs,
      Previous = unname(before_versions[removed_pkgs]),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
    cat("Removed packages:\n")
    print(removed_tbl)
  }
}

cat("\nFinal status: ", if (update_failed) "FAILURE" else "SUCCESS", "\n", sep = "")
if (!is.null(update_error)) {
  cat("Failure reason: ", update_error, "\n", sep = "")
}
cat("Done. Detailed log written to: ", log_file, "\n", sep = "")

if (update_failed) {
  quit(save = "no", status = 1)
}
