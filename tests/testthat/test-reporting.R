context('test report_dictionary')


library(fs)
library(ggplot2)



test_that('Output file types are correct', {
  skip_on_cran()
  
  rmd_file <- tempfile(fileext = '.Rmd')
  html_file <- tempfile(fileext = '.html')
  
  # short table
  pplr_report_dictionary(md_file = rmd_file,
                         html_file = html_file)
  
  expect_equal(sum(grepl('*[.]Rmd|*[.]html', fs::dir_ls(tempdir()))), 2)
  
  # Cleanup for next test
  paths <- fs::dir_ls(tempdir())[grepl('*[.]Rmd|*[.]html|*[_]files',
                                       fs::dir_ls(tempdir()))]
  
  fs::file_delete(paths)
  
  # long table
  pplr_report_dictionary(full_tbl = TRUE, 
                         md_file = rmd_file,
                         html_file = html_file)
  
  expect_equal(sum(grepl('*[.]Rmd|*[.]html', fs::dir_ls(tempdir()))), 2)
  
  # Cleanup for next test
  paths <- fs::dir_ls(tempdir())[grepl('*[.]Rmd|*[.]html|*[_]files',
                                       fs::dir_ls(tempdir()))]
  
  fs::file_delete(paths)

  
})

test_that('report_metadata can use all types of input', {
  skip('passes interactively and in devtools::test, but not in devtools::check()')
  
  browse_rmd_file <- tempfile(fileext = '.Rmd')
  browse_html_file <- tempfile(fileext = '.html')
  
  g_d_rmd_file <- tempfile(fileext = '.Rmd')
  g_d_html_file <- tempfile(fileext = '.html')
  
  
  # browse
  pplr_report_metadata(pplr_browse(lterid == 'MCR'), 
                       md_file = browse_rmd_file,
                       html_file = browse_html_file)
  
  expect_equal(sum(grepl('*[.]Rmd|*[.]html', fs::dir_ls(tempdir()))), 2)
  
  # Cleanup for next test
  paths <- fs::dir_ls(tempdir())[grepl('*[.]Rmd|*[.]html|*[_]files',
                                       fs::dir_ls(tempdir()))]
  
  fs::file_delete(paths)
  
  
  # Get_data
  
  pplr_report_metadata(pplr_get_data(lterid == 'MCR'),
                       md_file = g_d_rmd_file,
                       html_file = g_d_html_file)
  
  expect_equal(sum(grepl('*[.]Rmd|*[.]html', fs::dir_ls(tempdir()))), 2)
  
  paths <- fs::dir_ls(tempdir())[grepl('*[.]Rmd|*[.]html|*[_]files',
                                       fs::dir_ls(tempdir()))]
  
  fs::file_delete(paths)
  
})