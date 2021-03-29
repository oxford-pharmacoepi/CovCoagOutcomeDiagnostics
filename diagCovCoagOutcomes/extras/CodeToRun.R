

# Build the package
# Build, install and restart
library(diagCovCoagOutcomes)

#install.packages("renv") # if not already installed, install renv from CRAN
renv::activate() # activate renv
renv::restore() # this should prompt you to install the various packages required for the study

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(plotly)
library(magrittr)

# Specify where the results files will be saved:
outputFolder <- "...."

# Optional: specify where the temporary files will be created:
options(andromedaTempFolder = "C/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails("....")
oracleTempSchema <- NULL
cdmDatabaseSchema <- "...."
cohortDatabaseSchema <- "...."
cohortTable <- "diagCovCoagOutcomesCohorts" 
databaseId <- "...."
databaseName <- "...."
databaseDescription <- "...."

# Use this to run the cohorttDiagnostics. 
# The results will be stored in the diagnosticsExport subfolder of the outputFolder. 
# This can be shared between sites.
diagCovCoagOutcomes::runCohortDiagnostics(connectionDetails = connectionDetails,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     cohortDatabaseSchema = cohortDatabaseSchema,
                                     cohortTable = cohortTable,
                                     oracleTempSchema = oracleTempSchema,
                                     outputFolder = outputFolder,
                                     databaseId = databaseId,
                                     databaseName = databaseName,
                                     databaseDescription = databaseDescription,
                                     createCohorts = TRUE,
                                     runInclusionStatistics = TRUE,
                                     runIncludedSourceConcepts = TRUE,
                                     runOrphanConcepts = TRUE,
                                     runTimeDistributions = TRUE,
                                     runBreakdownIndexEvents = TRUE, 
                                     runIncidenceRates = TRUE,
                                     runCohortOverlap = TRUE,
                                     runCohortCharacterization = TRUE,
                                     runTemporalCohortCharacterization = TRUE,
                                     minCellCount = 5)

# To view your results:
CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, "diagnosticsExport"))
CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))


