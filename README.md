CovCoagOutcomeDiagnostics- CohortDiagnostics package to assess coagulopathy outcomes of interest
========================================================================================================================================================

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Preliminary results available">

- Type: **CohortDiagnostics**
- Results explorer: **[ShinyApp](https://livedataoxford.shinyapps.io/CovCoagOutcomesCohorts/)**
- Protocol: ** **
- Publications: ** **

## Running the analysis
1) Download this entire repository (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 
2) Open the project CovidCoagulopathyDiagnostics/diagCovCoagOutcomes/diagCovCoagOutcomes.Rproj in RStudio (when inside the project, you will see its name on the top-right of your RStudio session)
3) Open the diagCovCoagOutcomes/extras/CodeToRun.R file which should be the only file that you need to interact with< ul>
<li> First, build the package (build -> install and restart)</li> 
<li> Then run renv::activate() and renv::restore() to bring in the required packages to be used</li> 
<li> Next, <ul>
<li> outputFolder <- "....": Add your database specific information</li> 
<li> options(andromedaTempFolder = "C/andromedaTemp"): To specify andromedaTempFolder location </li> 
<li> maxCores <- parallel::detectCores(): To specify how many cores to use</li> 
<li>connectionDetails <- createConnectionDetails("........."): These are the connection details for the 
<a href="http://ohdsi.github.io/DatabaseConnector">OHDSI DatabaseConnector</a> package.Note, this is v4.0.0 of DatabaseConnector and so you will need to have downloaded the relevant drivers (see <a href="http://ohdsi.github.io/DatabaseConnector/articles/UsingDatabaseConnector.html">here</a> for more details) and pass the <i>pathToDriver</i> argument to the <i>createConnectionDetails</i> command.</li>
<li>cdmDatabaseSchema <-".....": This is the name of the schema that contains the OMOP CDM with patient-level data </li> 
<li>cohortDatabaseSchema <-".....": This is the name of the schema where a results table will be created </li>
<li>cohortTable   <- "diagCovCoagOutcomesCohorts" : This is the name of the table that will be created in the results schema (which could be called "diagCovCoagOutcomesCohorts" or something else - note, any existing table in your results schema with this name will be overwritten) </li> 
<li>databaseId <-".....": This is the short name/ acronym for your database</li>  
<li>databaseName <- "....": This is the full name of your database</li>  
<li>databaseDescription <- "....": A brief description your database</li>  
<li> After adding these details, you should then be able to run the line <i>diagCovCoagOutcomes::runCohortDiagnostics(...)</i> line which will run all of the required analyses. Once run, you can view you results by running the lines <i>CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, "diagnosticsExport"))</i> and <i>CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))</i></li> </ul>
