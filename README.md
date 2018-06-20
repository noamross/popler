
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/AldoCompagnoni/popler.svg?branch=master)](https://travis-ci.org/AldoCompagnoni/popler) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/AldoCompagnoni/popler?branch=master&svg=true)](https://ci.appveyor.com/project/AldoCompagnoni/popler) [![Coverage status](https://codecov.io/gh/AldoCompagnoni/popler/branch/master/graph/badge.svg)](https://codecov.io/github/AldoCompagnoni/popler?branch=master)

Popler
------

Popler is an R package for querying the *Popler* data base. It connects to an SQL data base that contains information on long term population dynamics studies from the US LTER network. Currently, it is only available on GitHub, but will hopefully be on CRAN soon.

### Installation

------------------------------------------------------------------------

``` r
# Install stable version once on CRAN (hopefully soon!)
install.packages('popler')


# Install development version now
if(!require(devtools, quietly = TRUE)) {
  install.packages(devtools)
}

devtools::install_github('AldoCompagnoni/popler')
```

### Dictionary of variables

------------------------------------------------------------------------

All exported functions use the `pplr_` prefix and lazy and/or tidy evaluation, meaning you do not need to manually quote most inputs. Once installed, you can explore the variables in the data base using the `pplr_dictionary()` function. This will give you a better idea of what each variable means and assist in refining queries for the next step. Additionally, there is the `pplr_report_dictionary()` function which generates an .Rmd file and renders it into html.

``` r
library(popler)

pplr_dictionary()
```

### Browsing `popler`

------------------------------------------------------------------------

Once you have become acquainted with the various types of data in the data base, the next step is to use the `pplr_browse()` function to view the variables associated with a given project. `pplr_browse()`can accept a logical condition (e.g. `duration_years > 5`), a given set of variables using the `vars` argument, or a keyword string using the `keyword` argument. These all generate a `tbl` that inherits from the `browse` class.

``` r
all_studies <- pplr_browse()

long_studies <- pplr_browse(duration_years > 20) # ... is not quoted!

parasite_studies <- pplr_browse(keyword = 'parasite') # but keyword is quoted

interesting_studies <- pplr_browse(vars = c('duration_years', 'lterid')) # so are vars

# Use full_tbl = TRUE to get a table with all possible variables

all_studies_and_vars <- pplr_browse(full_tbl = TRUE)
```

### Reporting metadata

------------------------------------------------------------------------

After browsing the list of projects, you can generate a report containing the metadata for all the projects included in the `browse` object using the function `pplr_report_metadata()`. This automatically generates an html file with the metadata and uses `rmarkdown` to render it to human-readable form. This may be preferable to the examining the `pplr_browse()` for some users.

``` r
# generate metadata report for all studies

pplr_report_metadata(all_studies)

# parasite metadata

pplr_report_metadata(parasite_studies)
```

### Downloading data

------------------------------------------------------------------------

Now that you've had the opportunity to explore the metadata and decide on the criteria for projects you'd like to download, it's time to actually download the data! This is done using the `pplr_get_data()` function. This connects to the data base and downloads the raw data based on the criteria supplied. Alternatively, if you're happy with the `browse` object you created earlier, you can simply pass that in and `popler` will take care of the rest. You can also fine-tune the data passed back by supplying strings to `add_vars` and `subtract_vars` which add additional columns to the default data or remove default columns. Finally, the `cov_unpack` argument allows you automatically expand covariates for each project/site and append them to the downloaded data. All objects created with `pplr_get_data()` inherit from `get_data` and `data.frame` classes.

``` r
# create a browse object and use it to get data

penguins <- pplr_browse(lterid == 'PAL')

# unpack covariates as well

penguin_raw_data <- pplr_get_data(penguins, cov_unpack = TRUE)

# A very specific query

more_raw_data <- pplr_get_data((proj_metadata_key == 43 | 
                                proj_metadata_key == 25) & 
                                year < 1995 )
```

### Data manipulation

------------------------------------------------------------------------

`popler` supplies methods for a couple `dplyr` verbs to assist with data manipulation. `filter` and `mutate` methods are available for objects of `browse` and `get_data` classes. Other `dplyr` verbs change the structure of the object too much for those classes to retain their meaning so they aren't included in the package, but one can still use them for their own purposes.

``` r
penguins_98 <- filter(penguin_raw_data, year == 1998)

class(penguins_98) # classes are not stripped from objects

penguins_98_true <- mutate(penguins_98, penguins_are = 'Awesome')

class(penguins_98_true)
```

### Data validation

------------------------------------------------------------------------

Data in `popler` can be replicated spatially at up to 4 levels of nestedness. The coarsest resolution is `spatial_replication_level_1`, and most data sets have at least 1 additional level of spatial replication (`spatial_replication_level_2`). These can refer to plots nested within transects nested within sites, for example. `spatial_replication_level_x_label` columns provide this information. As a user, you may only be interested in seeing data that is replicated at some minimum frequency for some minimum duration. We provide two functions for assisting you in finding this information. Note that both require a `get_data` object as `browse` objects do not contain enough information to determine these criteria.

`pplr_site_rep()` produces either a logical vector for subsetting an existing `get_data` object or a summary table of temporal replication for a given spatial resolution. You can control the minimum frequency of sampling and the minimum duration of sampling using the `freq` and `duration` arguments, respectively. Additionally, you can choose to filter based on whatever level of spatial replication you wish (provided it is present in the data) using the `rep_level` argument. `return_logical` allows you to control the format that is returned. `TRUE` returns a logical vector corresponding to rows in the `get_data` object that are in spatial replicates that meet the criteria. `FALSE` returns a summary table describing the number of samples per year at the selected spatial resolution.

`pplr_site_rep_plot()` produces a plot detailing whether or not a given *site* (e.g. `spatial_replication_level_1`) was sampled in a year. You can use the `return_plot` argument to control whether or not to return the `ggplot` object (useful for modifying the plot manually) or an invisible copy of the input data (useful for piping in a sequence of operations).

``` r
# Example with piping and subsetting w/ the logical vector output

library(dplyr)

SEV_studies <- pplr_get_data(lterid == 'SEV')


long_SEV_studies <- SEV_studies %>%
  .[pplr_site_rep(input = .,
                  duration = 12,
                  rep_level = 3), ] %>%
  pplr_site_rep_plot()

# Or, create the summary table

SEV_summary <- SEV_studies %>% 
  pplr_site_rep(duration = 12,
                rep_level = 3,
                return_logical = FALSE)


# Modify the site_rep_plot() by hand using ggplot2 syntax
library(ggplot2)

pplr_site_rep_plot(long_SEV_studies, return_plot = TRUE) +
  ggtitle('Sevilleta LTER Temporal Replication')
```

### Further information

------------------------------------------------------------------------

`popler` contains a number of vignettes that contain additional information on its various uses. However, if they do not cover your particular use case, you still have questions, or you discover a bug, please don't hesitate to create an [issue](https://github.com/AldoCompagnoni/popler/issues).
