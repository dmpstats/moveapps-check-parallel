library(move2)
library(lubridate)
library(furrr)
library(future)
library(dplyr)
library(progressr)
library(units)

rFunction <- function(data) {
  
  logger.info("Okay, let's check if parallelization is working!")
  
  # Set Globals ------------------------------------------------------------
  
  # track column
  trk_col <- mt_track_id_column(data)
  
  # set progress bar
  progressr::handlers("cli")
  
  # Parallel Processing ------------------------------------------------------------
  
  #' get available cores from {parallelly} via {future}, which  is safe to use in
  #' container environments (e.g. Docker)
  n_workers <- future::availableCores(omit = 1)
  
  logger.info(paste("Number of cores currently available for parallel processing: ", n_workers))
  
  #' setting parallel processing strategy
  future::plan("cluster", workers = n_workers)

  logger.info("Performing track-level tasks in parallel")  
  
  # parallel processing - one track id per worker
  with_progress({
    
    p <- progressr::progressor(steps = mt_n_tracks(data))
    
    prl_start <- Sys.time()
    
    data_par <- data |> 
      dplyr::group_by(.data[[trk_col]]) |>
      dplyr::group_split() |>
      furrr::future_map(.f = foo, p = p)
    
    prl_end <- Sys.time()
  })
  
  
  future::plan("sequential")
  
  # Sequential Processing ------------------------------------------------------------
  logger.info("Performing track-level tasks sequentially")
  
  # repeat via sequential processing
  with_progress({
    
    p <- progressr::progressor(steps = mt_n_tracks(data))
    
    seq_start <- Sys.time()
    
    data_seq <- data |> 
      dplyr::group_by(.data[[trk_col]]) |>
      dplyr::group_split() |> 
      furrr::future_map(.f = foo, p = p)
    
    seq_end <- Sys.time()
  })
    
  
  
  # Report runtimes -------------------------------------------------------------
  logger.info(
    paste0(
      "Runtime:\n",
      "\t- Parallel Processing: ", round(difftime(prl_end, prl_start, units = "s"), 3), "secs\n",
      "\t- Sequential Processing: ", round(difftime(seq_end, seq_start, units = "s"), 3), "secs\n"
    )
  )
  
  return(data)
}



#' Simple function with a couple of calls to move2, dplyr and lubridate
#' functions. Also testing the incorporation of a progress bar
foo <- function(dt, p){
  
  logger.info(paste0("  |> Processing track ", unique(mt_track_id(dt))))

  tm_col <- move2::mt_time_column(dt)
  speed_lim <- units::as_units(2, "km/h")

  dt$speed <- move2::mt_speed(dt, units = "km/h")

  dt <- dt |>
    dplyr::mutate(hour = lubridate::hour(.data[[tm_col]])) |>
    dplyr::filter(speed > speed_lim)

  Sys.sleep(5)
  p()
  
  return(dt)
}