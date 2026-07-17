<!-- README.md is generated from README.Rmd. Please edit that file -->

# pericircumference

<!-- badges: start -->
<!-- badges: end -->

A project manager designed for workflows that generate reports, slides,
or any other type of markdown output, `pericircumference` starts new
projects with a standard workflow designed for analysts in Perisphere
Real World Evidence.

## Installation

You can install the development version of pericircumference like so:

    renv::install("perisphere-rwe/pericircumference")

## Purpose

`pericircumference` populates working directories with relevant files to
manage your project using the `targets` package. It’s intended purpose
is to allow new projects to be initiated quickly and safely (e.g.,
without forgetting to write something important in `.gitignore`).

## File contents

Running `use_pericircumference()` in the R console will populate your
current working directory with the following files and directories:

- `_targets.R`: this is the file used to coordinate targets
- `packages.R`: all `library` calls go here
- `conflicts.R`: uses `conflicted` package to manage name space
- `changelog.md`: describes changes implemented in each update (more on
  this below)
- `.gitignore`: manages which files and directories are ignored by git
- the `R` directory:
  - `R/create_output_directories.R`: helper function used for updates
    (more on this below)
  - `R/summarize_each_group.R` and `R/flextable.R`: only added when
    `include_tutorials = TRUE`, since the tutorial report/slides
    templates call `summarize_each_group()`, `flextable_polish()`, and
    `flextable_polish_ppt()`.

Optional helper scripts are **not** added automatically (other than
`summarize_each_group.R`/`flextable.R` for tutorials, as noted above).
Add them on demand with the `use_helpers_*()` family:

- `use_helpers_flextable()`: adds `R/flextable.R`, helper functions for
  styling `flextable` objects.
- `use_helpers_datatable()`: adds `R/shift.R`, wrappers around
  `data.table::shift()` that make the shift direction explicit.
- `use_helpers_tidyverse()`: adds `R/summarize_each_group.R` (see above)
  — useful to run explicitly for non-tutorial projects.
- `use_helpers_market_clarity()`: adds `R/market_clarity.R`, containing
  `connect_to_db()` for connecting to Market Clarity data (a local
  DuckDB “mini” database or the full Databricks cluster).
- the `report` directory:
  - `report.Rmd`: generates the project report (can be MS word or html)
  - miscellaneous template files for styling the report
- the `slides` directory:
  - `slides.Rmd`: generates the project slides (can be MS word or html)
  - miscellaneous template files for styling the report

## Tutorial

This tutorial walks through the typical workflow for a new project:
initializing the project, running the pipeline, making an update,
documenting it in the changelog, and finalizing the version.

### Before you begin: add `pericircumference` to your `.Rprofile`

Since `pericircumference` functions are console commands used to set up
and manage projects — not part of any analysis pipeline — it’s
convenient to load the package automatically in every R session. The
right place to do this is your `.Rprofile`. You can open it with
`usethis`:

    usethis::edit_r_profile()

Then add the following and save the file:

    if (interactive()) {
      library(pericircumference)
    }

Restart R and the package will be available in every interactive session
without needing to call `library()` manually. The `if (interactive())`
guard ensures the package is not loaded when R is invoked
non-interactively (e.g., during `tar_make()` or on a CI server). More
broadly, this does not cause reproducibility issues because
`pericircumference` is only ever used in the console — functions like
`use_pericircumference()` and `finalize_version()` manage your project
setup and are never called from within the pipeline itself.

### Step 1: Initialize the project

In a fresh RStudio project, run:

    use_pericircumference(include_tutorials = TRUE)

This populates your working directory with all the files described in
the [File contents](#file-contents) section above. Because
`include_tutorials = TRUE`, the generated `_targets.R` includes a worked
example using the `palmerpenguins::penguins` dataset.

### Step 2: Review `_targets.R`

Open `_targets.R`. It is organized into four sections.

**Version guard and setup.** At the top, two variables control the
output file names:

    version_major <- 0
    version_minor <- 1

Immediately after, `assert_valid_version()` checks that you haven’t
accidentally reused a version number that has already been finalized.
This protects previously delivered documents from being overwritten.
`create_output_directories()` then creates version-specific output
folders (e.g., `report/report-v0/`) if they don’t already exist.

**Data target.** The `data` target loads the penguins dataset:

    data = palmerpenguins::penguins,

Replace this with your own data loading logic as you adapt the template.

**Meta target.** The `meta` target builds a data dictionary that
attaches human-readable labels, units, and category ordering to variable
names. This dictionary is used downstream by rendering functions to
produce clean, consistently labeled tables and figures:

    meta = as_data_dictionary(data) %>%
      set_labels(species = "Species", body_mass_g = "Body mass", ...) %>%
      set_units(bill_length_mm = "mm", ...) %>%
      ...

**Stats target.** The `stats` target computes summary statistics grouped
by species, then converts the results into an inline-reporting format
using `as_inline()`. The `.group_level` and `name` columns become keys
you reference directly in the report or slides:

    tar_target(stats, command = {
      data %>%
        group_by(species) %>%
        summarize_each_group(
          mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
          mean_mass        = mean(body_mass_g, na.rm = TRUE),
          sd_mass          = sd(body_mass_g, na.rm = TRUE),
          nobs             = n()
        ) %>%
        pivot_longer(cols = c(mean_bill_length, mean_mass, sd_mass, nobs)) %>%
        select(-.group_variable) %>%
        as_inline(tbl_variables = c(".group_level", "name"),
                  tbl_values    = "value")
    })

**Rendering targets.** At the bottom, `tar_render()` targets knit the
report and slides, writing the output to version-stamped file paths so
that each finalized version is preserved:

    tar_render(
      report,
      path        = here::here("report/report.Rmd"),
      output_file = paste0("report-v", version_major, "/",
                           "report-", basename(here()),
                           "-v", version_major, "-", version_minor, ".docx")
    )

### Step 3: Run the pipeline

With `_targets.R` saved, run the pipeline from the R console:

    targets::tar_make()

This produces your first set of outputs,
e.g. `report/report-v0/report-my-project-v0-1.docx` and
`slides/slides-v0/slides-my-project-v0-1.pptx`. These are your version
0.1 deliverables.

### Step 4: Review `changelog.md`

Open `changelog.md`. It will contain some instructional text at the top
explaining the purpose and format of the file, followed by example
version entries illustrating the expected format — read through it, then
delete all of it. Replace it with your own version 0.1 entry describing
what the initial results contain:

    ## Version 0.1

    - Created initial versions of tables and figures

### Step 5: Finalize version 0.1

Once you are ready to share the version 0.1 results with collaborators,
run:

    finalize_version(major = 0, minor = 1)

This saves `"0.1"` to `version.rds`, prints the changelog entries to
your console (copy and paste into your email), and reminds you to
increment the version number in `_targets.R` and make a git commit.
Follow those reminders now: change `version_minor` to `2` in
`_targets.R` and commit with the message `"finalize version 0.1"`.

### Step 6: Update `_targets.R`

Suppose you want to add mean flipper length to the summary statistics.
Edit the `stats` target in `_targets.R` to include the new variable:

    summarize_each_group(
      mean_bill_length    = mean(bill_length_mm, na.rm = TRUE),
      mean_flipper_length = mean(flipper_length_mm, na.rm = TRUE),  # new
      mean_mass           = mean(body_mass_g, na.rm = TRUE),
      sd_mass             = sd(body_mass_g, na.rm = TRUE),
      nobs                = n()
    ) %>%
    pivot_longer(cols = c(mean_bill_length,
                          mean_flipper_length,                      # new
                          mean_mass, sd_mass, nobs)) %>%

### Step 7: Apply the data dictionary in `report.Rmd`

Open `report.Rmd`. In the `setup-dictionary` chunk near the top, you
will find:

    set_default_dictionary(meta)

This registers `meta` as the default dictionary for the session. From
this point on, `translate_data()` — used to rename raw variable names to
human-readable labels — can be called without explicitly passing `meta`.
You will use this in the table and figure steps below.

### Step 8: Add an inline statistic

The `setup-formatters` chunk in `report.Rmd` creates two short aliases
for formatting results:

    tv <- periglue::peri_value  # formats a single number
    tg <- periglue::peri_glue   # formats with a template string

The `stats` target is loaded at the top of the document and organized as
a named list. The top level is the grouping variable value (e.g.,
`Adelie`, `Chinstrap`, `Gentoo`, and `.overall` for the full sample),
and the second level is the statistic name. To report the overall mean
flipper length inline, add a sentence to the text body of `report.Rmd`:

> The mean flipper length across all penguins was
> `r tv(stats$.overall$mean_flipper_length)` mm.

To report a species-specific value, index by species name instead:

> Among Adelie penguins, mean flipper length was
> `r tv(stats$Adelie$mean_flipper_length)` mm.

### Step 9: Create a new table

In the Tables section of `report.Rmd`, add a new subsection with a
flextable built from the raw `data`. Use `translate_data()` to apply the
dictionary to column headers, and use the `flextable_autofit()` and
`flextable_polish()` helpers from `R/flextable.R` (added automatically
because this tutorial project was initialized with
`include_tutorials = TRUE`) to style it:

    ## Table 2: Flipper and bill length by species

    ```{r}
    data %>%
      group_by(species) %>%
      summarise(
        n                   = n(),
        mean_flipper_length = mean(flipper_length_mm, na.rm = TRUE),
        mean_bill_length    = mean(bill_length_mm, na.rm = TRUE)
      ) %>%
      mutate(across(where(is.numeric), peri_value)) %>%
      translate_data(units = 'descriptive') %>%
      flextable() %>%
      flextable_autofit(prop_used_col_1 = 0.25) %>%
      flextable_polish(footer_text = abbrvs_write(abbrvs['mm']))
    ```

`translate_data(units = 'descriptive')` replaces raw column names (e.g.,
`mean_flipper_length`) with the labels and units defined in `meta`
(e.g., `"Flipper length (mm)"`). `flextable_autofit()` distributes
column widths proportionally, and `flextable_polish()` applies
consistent font, borders, and an abbreviations footer.

### Step 10: Add a landscape figure

For a figure that benefits from extra horizontal space, use the
`page_long_above()` / `page_wide_above()` pair. In Word,
`block_section()` calls apply their orientation to all content *above*
them back to the previous block section. The two helpers exploit this:
`page_long_above()` closes the current portrait section and
simultaneously triggers landscape figure dimensions (11 × 6 inches) for
chunks below it; `page_wide_above()` then closes that section as
landscape and resets figure dimensions to portrait for what follows.

Add the following to the Figures section of `report.Rmd`:

    `r page_long_above()`

    ## Figure 1: Bill length vs. flipper length

    ```{r}
    ggplot(data, aes(x = bill_length_mm, y = flipper_length_mm, color = species)) +
      geom_point()
    ```

    `r page_wide_above()`

The `page_long_above()` call above the heading switches the figure chunk
below it to 11 × 6 inch dimensions. `page_wide_above()` at the end marks
all content between the two calls as landscape in the Word document and
returns subsequent content to portrait.

### Step 11: Document the changes in `changelog.md`

Add a new version section **at the top** of `changelog.md`, above the
existing `## Version 0.1` entry:

    ## Version 0.2

    - Added mean flipper length to the species summary statistics
    - Added Table 2 showing mean flipper and bill length by species
    - Added Figure 1 (landscape) showing bill length vs. flipper length by species

Write changelog entries as you implement changes — not after the fact.
This makes it much easier to communicate exactly what changed when it is
time to share the update.

### Step 12: Rebuild the pipeline

Run `tar_make()` again:

    targets::tar_make()

Only the targets that depend on your change (in this case `stats`,
`report`, and `slides`) will re-execute. The new outputs land in
`report/report-v0/report-my-project-v0-2.docx` and
`slides/slides-v0/slides-my-project-v0-2.pptx`, while the version 0.1
files remain untouched.

### Step 13: Finalize version 0.2

When you are ready to share the updated results, run:

    finalize_version(major = 0, minor = 2)

This prints the version 0.2 changelog entries to your console for
copying into an email. Follow the same reminders as before: increment
`version_minor` to `3` in `_targets.R` and commit with the message
`"finalize version 0.2"`.

## Project management

This section focuses on Perisphere Real World Evidence and our own
approach to managing projects.

**Updates**: As the project matures, we periodically send results to our
team in a report, or present them using slides. We define these events
as project updates. To make sure there is a clear track record of
changes between each project update, we follow a standard procedure:

1.  All projects start at version 0.1, with version increments based on
    minor and major updates.

    - Version 0.1 is considered complete when we are ready to send the
      first draft of results to a collaborator. It does not necessarily
      need to contain all of the planned outputs.

    - The first version of results that contains all planned outputs for
      a project is called version 1.0.

    - *Example*: if a project has three objectives, we may want to share
      results with a collaborator after completing some results in
      objective 1. We’d call this version 0.1. For version 0.2, we could
      make minor updates to the results we shared in version 0.1 based
      on feedback from our collaborators. For version 0.3, we could
      complete results for objective 2. For version 0.4, we again make
      minor updates to results in objectives 1 and 2 based on feedback
      from our collaborators. Next, we complete results for objective 3,
      and because this consitutes all the results in the current
      project, we call this version 1.0. If we make minor updates to the
      analysis after this, we increment the minor version (e.g., 1.1,
      1.2, etc.). If we make a major update to the analysis after this
      (e.g., adding a fourth objective), we increment the major version
      (e.g., 2.0). This establishes a clear version history of results.

2.  The lead analyst writes changes in the changelog **as they implement
    them**.

    - To make sure your collaborators are kept informed as a project
      progresses, all meaningful updates to the project should be
      communicated to them. Proactively writing the changes in your
      changelog is the best way to do this. If you postpone summarizing
      changes, you’ll spend extra time wracking your brain trying to
      remember what you did and you might forget some important things
      (ask me how I know).

3.  When it’s time to share the changes, the analyst runs
    `finalize_version()`, which will do the following:

    - pull the text from the changelog file and print it to your
      console. You can copy/paste the text into an e-mail.

    - reminds you to change `version_major` and/or `version_minor` in
      your project so that the next time you make your targets, any
      rendered markdown documents will be made with the new version name
      (this ensures you won’t accidentally overwrite a previously
      finalized report).

    - reminds you to make a git commit indicating that this is the
      commit where a given version was finalized. This makes it easy to
      rewing the project to previous versions if needed.

## Using git

It is highly recommended to use `git` in projects that are created with
`use_pericircumference`, but it isn’t a requirement. Personally, `git`
is my preference for version control of code documents (e.g., files
ending in `.R`, `.Rmd`, or `.qmd`), while `finalize_version()` is my
preference for version control of documents created by code (e.g., files
ending with `.docx`, `.html`, or `.pdf`). I prefer `pericircumference`
for version control of output documents because it keeps all the
previous versions accessible to you without having to navigate through
commit history to fish them out, and in general using `git` to track
`.docx` or other types of output files can be awkward because it is a
little out of scope for `git` to do this.

## Common errors

1.  **I ran `tar_make()` and got this error: pandoc document conversion
    failed with error 1**. This error occurs when you attempt to knit a
    word document while the document is open on your computer. To fix,
    close the document and try running `tar_make()` again.

2.  **I ran `tar_make()` and got an error, but there is no error message
    printed in my console**. This can happen when `crew` is used to run
    `targets` pipelines. Run `tar_make(as_job = FALSE)` to prevent
    `crew` from being used - this should make the error message print to
    your console as usual.

3.  **I made changes to `_targets.R` and then ran `tar_make()` but the
    changes were not incorporated**. Double check to see if you saved
    your `_targets.R` file after making changes. The same goes for
    making changes to other R files that `_targets.R` uses.
