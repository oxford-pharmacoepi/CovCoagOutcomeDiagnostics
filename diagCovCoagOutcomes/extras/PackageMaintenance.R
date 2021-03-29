# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of diagCovCoagOutcomes
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("diagCovCoagOutcomes")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/diagCovCoagOutcomes.pdf")
shell("R CMD Rd2pdf ./ --output=extras/diagCovCoagOutcomes.pdf")


# Insert cohort definitions from ATLAS into package -----------------------
ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreate.csv",
                                                 baseUrl = "http://10.80.192.22:8080/WebAPI",
                                                 insertTableSql = TRUE,
                                                 insertCohortCreationR = TRUE,
                                                 generateStats = TRUE,
                                                 packageName = "diagCovCoagOutcomes")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("diagCovCoagOutcomes")







library(ROhdsiWebApi)
library(dplyr)
library(here)

Atlas.ids<-
c("506", 
"555",
"568",
"570",
"507",
"553",
"508",
"554",
"567",
"566",
"559",
"560",
"510",
"557",
"509",
"558",
"511",
"572",
"512",
"573",
"513",
"561",
"514",
"562",
"581",
"582",
"574",
"575",
"577",
"578",
"586",
"593",
"587",
"594",
"588",
"595",
"590",
"596",
"591",
"597",
"592",
"598",
"517",
"580")


bring.in.cohorts<-function(){

# remove any existing cohorts 
unlink("inst/cohorts/*")
unlink("inst/sql/sql_server/*")
unlink("inst/settings/*")
  
# CohortsToCreate csv 
# atlasId	atlasName	cohortId	name
AllCohorts<-getCohortDefinitionsMetaData("http://10.80.192.22:8080/WebAPI")
# all cohorts in Atlas
CohortsToCreate<-AllCohorts %>% 
  filter(id %in% Atlas.ids) %>% 
  select(id, name) %>% 
  rename(atlasId=id,
         atlasName=name) %>% 
  mutate(cohortId=atlasId,
         name=atlasName)
write.csv(CohortsToCreate,
          row.names = FALSE,
          "inst/settings/CohortsToCreate.csv")
  
ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreate.csv",
                                                 baseUrl = "http://10.80.192.22:8080/WebAPI",
                                                 insertTableSql = TRUE,
                                                 insertCohortCreationR = TRUE,
                                                 generateStats = TRUE,
                                                 packageName = "diagCovCoagOutcomes")
if(file.exists(here("inst/cohorts/InclusionRules.csv"))==FALSE){
write.csv(data.frame(cohortName=character(),ruleSequence=character(),ruleName=character(),cohortId=character()),
          row.names = FALSE,
          "inst/cohorts/InclusionRules.csv")}
  
}
bring.in.cohorts()
