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





# other ----

library(ROhdsiWebApi)
library(CirceR)
library(dplyr)
library(tidyr)
library(here)
library(readr)
Sys.setenv(TZ='GMT')



Atlas.ids<-c("386",
             "388",
             "389",
             "390",
             "391",
             "392",
             "393",
             "394",
             "395",
             "396",
             "397",
             "398",
             "399",
             "400",
             "401",
             "402",
             "404",
             "405",
             "406",
             "407",
             "408",
             "409",
             "410",
             "411",
             "412",
             "413",
             "414",
             "415",
             "416",
             "417",
             "418",
             "419",
             "420",
             "421",
             "422",
             "423",
             "424",
             "425",
             "426",
             "427",
             "430",
             "431",
             "432",
             "434",
             "435",
             "436",
             "437",
             "438",
             "439",
             "440",
             "441",
             "442",
             "444",
             "445",
             "447",
             "448",
             "449",
             "451",
             "452",
             "453",
             "454",
             "455",
             "456",
             "457",
             "458",
             "459",
             "460",
             "461",
             "462",
             "463",
             "464",
             "465",
             "468",
             "469")
baseurl<-.rs.askForPassword("Atlas url:")
webApiUsername<-.rs.askForPassword("Atlas username:")
webApiPassword<-.rs.askForPassword("Atlas password:")
authorizeWebApi(baseurl,
                authMethod="db",
                webApiUsername = webApiUsername,
                webApiPassword = webApiPassword)

#trace(getDefinitionsMetadata, edit=TRUE)

bring.in.cohorts<-function(){

# remove any existing cohorts 
unlink("inst/cohorts/*")
unlink("inst/sql/sql_server/*")
unlink("inst/settings/*")

if(file.exists(here("inst/cohorts/InclusionRules.csv"))==FALSE){
  write.csv(data.frame(cohortName=character(),ruleSequence=character(),ruleName=character(),cohortId=character()),
            row.names = FALSE,
            "inst/cohorts/InclusionRules.csv")}
  
# CohortsToCreate csv 
# atlasId	atlasName	cohortId	name
AllCohorts<-getCohortDefinitionsMetaData(baseurl)
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
                                                 baseUrl = baseurl,
                                                 insertTableSql = TRUE,
                                                 insertCohortCreationR = TRUE,
                                                 generateStats = TRUE,
                                                 packageName = "diagCovCoagOutcomes")
}
bring.in.cohorts()


# summarise cohort sets definitions
CohortFullNames <- read_csv(here("extras/CohortFullNames.csv"))
describe.cohort.def<-function(id){
a<-  getCohortDefinition(id, baseurl)

def<-list()
for(n in 1:length(a$expression$ConceptSets)){
working.def<-list()   
for(i in 1:length(a$expression$ConceptSets[[n]]$expression$items)){
working.def[[i]]<-  data.frame(a$expression$ConceptSets[[n]]$expression$items[[i]]) %>% 
    mutate(name=a$expression$ConceptSets[[n]]$name)
}
working.def<-bind_rows(working.def)
working.def<-working.def %>% 
    select(name,concept.CONCEPT_ID, concept.CONCEPT_NAME,
           concept.VOCABULARY_ID,isExcluded, includeDescendants)
working.def 

def[[n]]<-working.def

  }
def<-bind_rows(def)
def

}

cohort.summary<-list()
for(c in 1:length(Atlas.ids)){
  print(c)
  working.name <- getCohortDefinitionsMetaData(baseurl) %>% 
    filter(id %in% Atlas.ids[[c]]) %>% 
    select(name)
  working.name <- working.name %>% 
    left_join(CohortFullNames,
              by="name") %>% 
    select(FullName) %>% 
    pull()
  if(!working.name %in% c("Death","Death (hospitalised)")){ # no concept set
  cohort.summary[[working.name]]<-describe.cohort.def(as.numeric(Atlas.ids[[c]]))
  }
}
save(cohort.summary, file=here("extras","cohort.summary.RDS"))

# summarise distinct concept sets
concept.sets<-bind_rows(cohort.summary) 
concept.sets<-concept.sets %>% 
  distinct()

concept.sets.wide<-concept.sets %>% 
  mutate(inc="Yes") %>% 
  pivot_wider(names_from = name, values_from = inc, values_fill="No")
concept.sets.wide<-concept.sets.wide %>% mutate_if(is.character,as.factor)
save(concept.sets.wide, file=here("extras","concept.sets.wide.RDS"))

concept.sets<-concept.sets %>%
  group_by(name) %>% 
  group_split()
save(concept.sets, file=here("extras","concept.sets.RDS"))

