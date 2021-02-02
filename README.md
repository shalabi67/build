# Improve build performance
## Problem statement
The existing build system takes more than 40 min to build. we want to improve this to be 20 min or better.
This is an example of the existing build command
`build/build.sh erfurt,italy,madrid logistics-test_release-staging,logistics-beta_beta,logistics-live_live $CDP_PIPELINE_ID`

## Research
### Exiting solution problem
The existing solution suffer from the following issues.
- There are two loops inside each other. the outer loop identify the environment, which is about three env. 
  On the other hand, the inner loop identify the applications. There are also three application. 
  The inner loop is used to generate properties files. this means there will be about 9 run.

- Another application inner loop is used to do:
  - maven build 
  - have an inner loop for applications which will do:
    - docker build for backend
    - docker push for backend
    - docker build for frontend
    - docker push for front end.
  

### Run system in parallel
In this research we assumed the following
- build will take 40 min
- properties build will take 54 seconds
- maven build will take 21 min
- publish to docker hub will take 18 min

The results were:
- Normal run took 39 min 54 seconds 
- parallel run took 8 min and 6 seconds

### run normal
`./normal.sh erfurt,italy,madrid logistics-test_release-staging,logistics-beta_beta,logistics-live_live CDP_PIPELINE_ID`

### run parallel
`./parallel.sh erfurt,italy,madrid logistics-test_release-staging,logistics-beta_beta,logistics-live_live CDP_PIPELINE_ID`
