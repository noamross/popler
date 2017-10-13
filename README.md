
<!-- README.md is generated from README.Rmd. Please edit that file -->
#### Changes in this fork of `popler` from [master branch](https://github.com/AldoCompagnoni/popler)

-   Updated Roxygen documentation to include all dependencies and updated NAMESPACE accordingly

-   Updated some documentation so that it is more clear and/or CRAN compliant

-   updated `alt icon` folder name to `alt_icon` to make it more portable

-   Edited buildignore to include some files that don't need to be made available in package

-   Added a couple options to default devtools::check/R CMD check settings so life is a bit easier in the pre-CRAN submission era

-   Moved the `explanations` and `explain_short` objects into an internally stored list called `R/sysdata.rda` to fix some NOTES from devtools::check(). I've added a script to recreate the data file in `data-raw/explanations.R`.

-   Removed calls from `summary_table_check` to `summary_table_update`. Basically, the only way that the user could not have the `summary_table.rda` file in their *extdata* folder is if they intentionally deleted it (it's installed as part of the package, so it should always be there). Additionally, if they have chosen to delete it, I assume they had a good reason to do so. Instead, I've exported the table's check function so anyone can use it to see how out of date they are. They can then call the update function manually instead. **Disclaimer: there are probably bugs in this reorganization**

#### Notes about this fork that are holdover problems from [master branch](https://github.com/AldoCompagnoni/popler)

1.  I have not actually fixed any of the functions or examples that fail due to the new `dbplyr` backend for the package. I am not sure I can fix them until discussing the structure of the database with current maintainers, so this will remain a problem until then (or one of them fixes it).

2.  Technically, this version is still failing `R CMD check` because of non-ASCII characters in `report_metadata`. This *must* be resolved before submitting to CRAN.

3.  This version is not passing `goodpractice::gp()` required by *ropensci*. Currently, the function itself fails on the package due to a malformed file error. I've traced this back to `R/report_metadata.R` and found that others have had [issues](https://github.com/jimhester/lintr/issues/252) with running **lintr**, so maybe we are having similar problem. I have not yet had time to scan through the function for the actual source of the error yet though.
