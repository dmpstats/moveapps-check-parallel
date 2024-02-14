# Test Parallel Processing

MoveApps

Github repository: *https://github.com/dmpstats/moveapps-check-parallel*

## Description
An example App to test and evaluate the use of parallel processing in the MoveApps system.

## Documentation
The sole purpose of this App is to provide a simple test-case for demonstrating parallel processing within the MoveApps framework. Parallelization is set via the `R` package [`furrr`](https://furrr.futureverse.org/index.html), which offers map-like functions to easily distribute and run tasks in parallel.

The output data is a replicate of the input data. Relevant outputs are provided in the App's Logs, which include:
- The number of cores available
- Run-time comparison between parallel and sequential processing

### Input data

A Move2 location object (`move2::move2_loc`)

### Output data

A Move2 location object (`move2::move2_loc`)


### Artefacts

None

### Settings 

None

### Most common errors

None so far


### Null or error handling

Not applicable