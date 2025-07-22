#
# Wastewater Surveillance Public Dashboard
#

# Library & functions -----
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(plotly)
library(leaflet)
library(leaflet.extras)
library(janitor)
library(lubridate)
library(tidyverse)
library(DT)
library(formattable)
library(catmaply)


`%notin%` <- Negate(`%in%`)


# Add the map reset button function from UDEQ's custom 'wqTools' package 
# (https://rdrr.io/github/utah-dwq/wqTools/man/addMapResetButton.html)
addMapResetButton <- function(leaf) {
  leaf %>%
    addEasyButton(
      easyButton(
        icon = "ion-arrow-shrink", 
        title = "Reset View", 
        onClick = JS(
          "function(btn, map){ 
                    map.setView(map._initialCenter, map._initialZoom);
                    }"
        )
      )
    ) %>% 
    htmlwidgets::onRender(
      JS(
        "
function(el, x){ 
  var map = this; 
  map.whenReady(function(){
    map._initialCenter = map.getCenter(); 
    map._initialZoom = map.getZoom();
  });
}"
      ))
}



# UI -----

## Create header -----

header <- dashboardHeader(title = "Utah Wastewater Surveillance System",
                          titleWidth = 375,
                          tags$li(a(href = "https://dhhs.utah.gov",
                                    img(src = "DHHS_logo_white_small.png",
                                        title = "Utah DHHS"),
                                    style = "padding-top: 5px; padding-bottom: 5px;"),
                                  class = "dropdown"))


## Define UI -----
ui <- dashboardPage(

  # This sets the title in the browser tab
  title = "Utah Wastewater Surveillance System",
  
  # Implement the header created above
  header,
  
  ## sidebar ------------------------------
  dashboardSidebar( 
    width = 225,
    sidebarMenu(
      
      # Initialize shinyjs
      useShinyjs(),
      
      id = 'sidebar',
      style = "position: fixed; overflow: visible;",

      ### SARS-CoV-2 tab -----
      menuItem("SARS-CoV-2 data", tabName = "Data_tab",
               icon = icon('chart-line')),
      
      ### Info tab -----
      menuItem("Info and methods", tabName = "Info_tab",
               icon = icon('globe')),
      
      ### FAQ tab -----
      menuItem("Frequently asked questions", tabName = "FAQ_tab",
               icon = icon('question')),
      
      ### Contacts tab -----
      menuItem("Contact us", tabName = "Contact_tab",
               icon = icon('envelope')),
      
      ### Date range input -----
      uiOutput("datemenu"),
      
      ### Date reset button -----
      actionButton("reset_date", "Reset dates"),
      
      ### Date input text -----
      p(HTML("&nbsp; Minimum date: 04/01/2020 <br><br>
             &nbsp; Changing the dates in the above <br>
             &nbsp; inputs only alters the data <br>
             &nbsp; displayed in the graphs. The map, <br>
             &nbsp; summary table, and info boxes will <br>
             &nbsp; always show data from the latest <br>
             &nbsp; samples. By default, the past two <br>
             &nbsp; years of data are displayed."), style = "font-size: 13px"),
      
      p(HTML("&nbsp; Note: date inputs are disabled <br>
             &nbsp; for legacy sites."), style = "font-size: 13px")

    )
  ),
  
  ## dashboard body -----
  dashboardBody(
    
    tags$head(
      # Import CSS
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      # Set favicon
      tags$link(rel = "shortcut icon", href = "favicon.ico"),
      #This hides temporary errors that flash when the dash will load anyways
      #If you are troubleshooting, comment this out
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      )
    ),
    
    # Fix the header and sidebar in place
    tags$script(HTML("$('body').addClass('fixed');")),
    
    # Sidebar item spacing (need to add space to prevent calendar-type date inputs from being too high)
    tags$head(tags$style(".sidebar-menu li { margin-bottom: 10px; }")),
    
    
## Tabs -----
    tabItems(
  
  ### SARS-CoV-2 tab -----
  tabItem(tabName = "Data_tab",
          
          h3("SARS-CoV-2 wastewater surveillance data"),
          p(HTML("<b>We made a major change to our SARS-CoV-2 assay in November 2024 which affects all data. Visit the 'Info and methods' tab 
            at the left for details.</b>")),
          p("Visit the 'Info and methods' tab on the left to see more detailed information on how our samples are collected,
            analyzed, and interpreted."),
          
          fluidRow(
            
          tabBox(width = 12,

           ### Site-specific subtab -----
           tabPanel(title = "Site-specific data",
           fluidRow(
             #### Base map -----
             box(title = "Click on a sampling site to populate the graphs below",
                width = 8,
                leafletOutput("combo_map",
                              height = "650px")),
            box(title = "Data notes",
                width = 4,
                p(HTML("<b>Concentration and trend</b>")),
                p(HTML("Concentration is categorized into a 6-tier system and indicated by the color of the map icon. Statistically
                       significant trends are indicated by map icon shape. Both are detailed in the map legend to the left.")),
                p(HTML("<b>Legacy sites</b>")),
                p(HTML("These are sites where samples are no longer being collected, although you can still see the data. 
                       Click the 'Show legacy sites' button in the bottom left corner of the map to show them.")),
                p(HTML("<b>County and LHD borders</b>")),
                p(HTML("To view the boundaries and names of counties or local health departments (LHDs), click on the corresponding
                       button in the bottom left corner of the map.")),
                p(HTML("<b>Map reset</b> <img src = 'map_reset.png'>")),
                p(HTML("To reset the map view and zoom to default status, click the reset button on the left side of the
                       map pane.")),
                p(HTML("<b>Search</b> <img src = 'search.png'>")),
                p(HTML("Click on the magnifying glass icon on the map to search by site name. Note that some wastewater 
                       facility names do not necessarily correspond to the communities they serve.")),
                ) # /Map Notes box
               ), # /fluidRow within tabPanel
            
           
          #### Value boxes ----
            fluidRow(
              valueBoxOutput("msd_name_valbox", width = 3),
              valueBoxOutput("msd_level6_valbox", width = 3),
              valueBoxOutput("pct_change_valbox", width = 3),
              valueBoxOutput("genomic_valbox", width = 3)
            ),
          
          #### Summary table -----
          p(HTML("<b>Click on the + at the right to expand the summary table.</b>")),
          fluidRow(
            box(
              width = 12,
              title = "Summary table",
              status = "info",
              collapsible = TRUE,
              collapsed = TRUE,
              #datatable here
              dataTableOutput("facilityTable")
            ) #end box
          ), #end fluidRow
          
          ## For troubleshooting
          # fluidRow(
          #   box(width = 12,
          #        #column(9, DT::dataTableOutput('x3')),
          #        column(3, verbatimTextOutput('x4'))
          #   )),
          
          
          #### Charts ------
          conditionalPanel( #conditionally reacts and adds boxes when valuebox exists
            
            condition = "output.msd_name_valbox",
          fluidRow(
            box(tags$style(type = "text/css", "#sew_ts {width: calc(97%) !important;}"),
                plotlyOutput("results_subplot",
                             height = "800px"),
                width = 12)
          ) # /fluidRow
          ) # /conditionalPanel
        ), # /"Site-specific tabPanel
          
          
          ### Statewide subtab -----
          tabPanel(title = "Statewide data",
                   
                   #### Heatmap, statewide -----
                   fluidRow(
                     box(title = "Statewide concentration category heatmap",
                         width = 12,
                         height = "750px",
                         plotlyOutput("heatmap_statewide")
                         ) # /box
                     ), # /fluidRow
                   
                   #### Genomic, statewide -----
                   fluidRow(
                     box(title = "Sequencing data: statewide variants",
                         width = 12,
                         height = "500px",
                         plotlyOutput("genomic_statewide")
                     ) # /box
                   ) # /fluidRow
                   
            ), # /"Statewide" tabPanel
          ), # /"SARS-CoV-2 data" tabBox
        ), # /fluidRow
          
  ), # /Data tab
  
  
  ### Info tab -----
  tabItem(tabName = "Info_tab",
          
          # title = "General information, data analysis, and interpretation",
          h3("General information, data analysis, and interpretation"),
          p(HTML("<br>")),
          p(HTML("<b><u>Important notes</u></b>:"), style = "font-size: 16px"),
          p(HTML("<ul>
                 <li><b>New</b>: On 2024-11-14, we moved our SARS-CoV-2 assay to a new, single gene target. Before that date, 
                  all SARS-CoV-2 data were based on the combined results from 2 different gene targets. Parallel testing of 
                  both methods showed that concentrations based on the previous 2 combined gene targets was almost exactly 1/2 
                  the value of concentrations based on the new, single gene target. To aid data comparability across lab methods, 
                  all historical data has been divided in half. Data trends, patterns, and interpretations remain unchanged.</li>
                 </ul>")),
          p(HTML("<ul>
                  <li>On 2024-2-28, we moved all quantification of wastewater surveillance samples from a qPCR
                  process to a ddPCR (droplet digital PCR) process. While parallel testing of both methods indicated
                  that the results are often very similar, we recommend using caution when interpreting or
                  combining data from before and after that date.</li>
                 </ul>")),
          p(HTML("<ul>
                  <li>On 2021-08-01 all laboratory analyses moved to the Utah Public Health Laboratory from 
                  academic partner labs. While data for many sites remained quite similar, some sites did display a 
                  noticeable shift. We recommend using caution when you interpret or combine data from before and 
                  after that date.</li>
                 </ul>")),
          
          p(HTML("</br>")),
          p(HTML("<b><u>Dashboard updates</u></b>"), style = "font-size: 16px"),
          p(HTML("The data displayed in this dashboard updates daily overnight. Note that new wastewater data will usually
                           be added twice per week, typically on Tuesdays (for samples collected the previous Thursday) 
                           and Fridays (for samples collected the previous Tuesday). Sampling may be cancelled for state 
                           and federal holidays due to a lack of available staff at our partner utilities.
                           <br><br>")),
          
          p(HTML("<b><u>Sampling</u></b>"), style = "font-size: 16px"),
          p(HTML("<b>Current sites</b>: 35 sites are sampled on Tuesdays and Thursdays. The majority of our 
                           partner utilities collect either flow- or time-weighted composite samples of roughly 24 hours 
                           duration (meaning sampling begins on Mondays or Wednesdays and ends on Tuesdays or Thursdays). 
                           Two sites (Snyderville Basin East Canyon and Snyderville Basin Silver Creek) collect 6-hour manual 
                           composite samples, and Roosevelt collects grab samples.
                           <br>")),
          p(HTML("<b>Missing data</b>: As routine sampling occurs twice per week, there are typically 5 days each week with no new 
                           data. Some graphs fill in data for those days with data from the previous sample. For example, 
                           Wednesdays use data from the previous Tuesday, and Fridays through Mondays use data from the 
                           previous Thursday. This process applies to the following:
                           <ul>
                           <li>The 'Historical concentration categories' graph on the 'Site-specific data' tab.</li>
                           <li>The 'Sequencing data' graph on the 'Site-specific data' tab.</li>
                           <li>The 'Statewide concentration category heatmap' on the 'Statewide data' tab.</li>
                           <li>The 'Sequencing data: statewide variants' graph on the 'Statewide data' tab.</li>
                           </ul><br>")),
          
          p(HTML("<b>New sites</b>: When we begin sampling at a new site, it takes some time before we can be confident 
                           when we categorize concentrations due to the method's reliance on site-specific historical data.
                           </br></br>
                 We currently have no new sites.</br></br>")),
          
          p(HTML("<b>Legacy sites</b>: There are currently 12 wastewater facilities where samples are no longer being
                           collected: Blanding City WWD, Daggett County WRF, Dutch John WRF,
                           Fillmore City SD, Gunnison City SD, Magna WWTP, Mona SD, Moroni WWTP, Monticello WWTP, Oakley WWTP, 
                           Richfield City SD, and Springdale SD. To see old data from these sites, click on the 'Show legacy 
                           sites' button on the map. Note the x-axis dates for these old data!
                 <br><br>")),
          
          p(HTML("<b><u>Wastewater data analysis and interpretation</u></b>"), style = "font-size: 16px"),
          p(HTML("We recommend you use trends and categorized concentrations (as described below) to compare data 
                           between sites. Given the large number of differences between sites in infrastructure, climate, population characteristics,
                           etc., we discourage direct comparisons or averaging of raw data between sites.
                           <br><br>")),
          p(HTML("<b>Dates</b>: Our analyses use the date sampling ended in our analyses. Thus, a sample whose collection 
                           began 10/02/23 and ended 10/03/23 would use a date of 10/03/23. Note that the CDC uses the date 
                           sampling began, so that same sample would use a date of 10/02/23 in their analyses.
                           <br><br>")),
          p(HTML("<b>Reporting limits</b>: The smallest concentration that can be reported by the laboratory is called 
                           the reporting limit. It is a function of the sensitivity of the lab instrument, aspects of the 
                           specific methods being used, and other factors. In essence, we are confident in the accuracy of 
                           values above the reporting limit, even though we don't know the true concentration for values below 
                           the reporting limit.")),
          p(HTML("Our most common reporting limit for SARS-CoV-2 is 12 copies/milliliter of wastewater, although this 
                           has varied somewhat with minor shifts in our methods. For analytical and display purposes, 
                           concentrations below the reporting limit are set to 1/2 of the reporting limit. Note that values 
                           below the reporting limit do not necessarily indicate a complete lack of cases in that sewershed.
                           <br><br>")),
          p(HTML("<b>Normalization and units</b>: Quantitative PCR results are normalized by the wastewater flow during
                           the sampling period and the estimated sewershed population. The resulting units are millions
                           of gene copies per person per day, or MGC/person/day.
                           <br><br>")),
          p(HTML("<b>Concentration</b>: Concentrations are categorized into a 6-tier system, from 'very low' to 'extremely elevated'. 
                           These categorizations are site-specific and a relative measure of concentration, meaning that 
                           it is valid to compare categories between sites. To determine the categorizations, quantile 
                           thresholds (20%, 40%, 60%, 80%, and 95%) are calculated using historical data from each site.
                           Each data point is compared against these site-specific thresholds and placed into the appropriate 
                           'bin' (0-20%, 60-80%, etc.). The concentration categories are:
                           <ul>
                            <li><u>Very low</u>: 0-20%. Data in this category is quite low compared to historical 
                                data from the site.</li>
                            <li><u>Low</u>: 20-40%. Data in this category is fairly low compared to historical 
                                data from the site.</li>
                            <li><u>Watch</u>: 40-60%. This is a middle category for data that, while not necessarily considered 
                                high, also can't be considered low.</li>
                            <li><u>Elevated</u>: 60-80%. Data in this category is considered somewhat high compared to 
                                historical data from the site.</li>
                            <li><u>Very elevated</u>: 80-95%. Data in this category is quite high compared to 
                                historical data from the site.</li>
                            <li><u>Extremely elevated</u>: 95+%. Data in this category is much higher than nearly all 
                                historical data from the site. It is intended to highlight the most extreme concentrations.</li>
                           </ul>
                           
                           Previously, we categorized concentrations into a 3-tier system, where the both low categories
                           (0-40%) were condensed together, and the 3 elevated categories (60-95+%) were condensed together.
                           <br><br>")),
          p(HTML("<b>Trend</b>: Trend identification is based on a linear regression of the log transformed 
                           results normalized for flow and population (i.e., our normal results transformed onto a log 
                           scale). Regressions are calculated over a 13-day period from the most recent sample, which 
                           normally includes 4 samples. The chosen significance level is 0.30; sites with regression
                           p-values above 0.30 are categorized with a trend of 'plateau/indeterminate'. Note that at least
                           3 samples in this 13-day period are required to derive a p-value. Sites with fewer than 3
                           samples in that 13-day period are flagged 'Insufficient recent data.'")),
          p(HTML("The 13-day percent change is based on the slopes from these regressions. Percent change is
                           not calculated when the slope is 'plateau/indeterminate' (i.e., when the slope is not significant).")),
          p(HTML("<u>Plateau/indeterminate</u> means that 
                           there was not a significant recent trend based on the above
                           criteria. Note that this does not indicate concentrations in the sewer system. The concentration 
                           in wastewater may be high, low, or in between relative to previous samples from that site.
                           <br><br>")),
          p(HTML("<b>Sequencing data</b>: Samples are sent for sequencing once or twice per week and may lag behind concentration data.
                            Until new data are received, sequencing visualizations will fill in days with data from the most recent 
                            previous sample.")),
          p(HTML("<u>Site-specific variants</u>: For each sampling day, we calculated the percentage each variant 
                           contributed to the total from that facility's sample. This provides a localized view of disease 
                           trends.")),
          p(HTML("<u>Statewide variants</u>: To calculate the statewide variant graph, we combined the data from all sites
                           across the state for each sampling day. Then, we calculated the percentage each variant 
                           contributed to the total from all samples from that day. This allows us to monitor trends and 
                           visualize how variants spread over time at the state level.
                          <br><br>")),
          
          p(HTML("<b><u>Case data</u></b>"), style = "font-size: 16px"),
          p(HTML("<b>Geocoding</b>: All COVID-19 cases in our database are assigned to a sewershed based on residential 
                           address at diagnosis. If a case cannot be geocoded due to missing or bad address information 
                           but has at least a ZIP code, it is randomly allocated to an appropriate sewershed with a 
                           probability based on the distribution of residential ZIP code addresses within various sewersheds.")),
          p(HTML("For example, take hypothetical ZIP code X that is partially covered by sewersheds A and B. 
                           If 31% of the residential ZIP code addresses are within sewershed A and 23% are within sewershed 
                           B, then such a case would be randomly allocated to sewershed A 31% of the time and to sewershed 
                           B 23% of the time.
                           <br><br>")),
          p(HTML("<b>Data suppression</b>: Following department protocol on data privacy and security, daily case counts between
                           1 and 4 (and metrics based on such counts, like case rates) are suppressed. This means that we 
                           do not display the actual count or rate. Instead, we replace the actual case count with a value 
                           of 2, which is the nearest whole number to the mean and median of all suppressed counts. Note 
                           that case data suppression tends to occur more frequently in sewersheds with smaller populations, 
                           as they typically have fewer cases on a given day.
                           <br><br>")),
          
          p(HTML("<b><u>National Wastewater Surveillance System (NWSS)</u></b>"), style = "font-size: 16px"),
          p(HTML("In response to the COVID-19 pandemic, CDC launched the National Wastewater Surveillance System (NWSS) 
                           in September 2020. CDC developed NWSS to coordinate and build the nation’s capacity to track 
                           the presence of SARS-CoV-2, the virus that causes COVID-19, in wastewater samples collected 
                           across the country. Utah was one of the initial 8 states to join this effort. Now, only
                           a few short years later, nearly all states and several cities participate.
                           <br>")),
          p(HTML("<u>Visit the NWSS website</u>: <a href = 'https://www.cdc.gov/nwss' target = '_blank'>www.cdc.gov/nwss</a>
                           <br>")),
          p(HTML("<u>View national wastewater surveillance data</u>: 
                           <a href = 'https://covid.cdc.gov/covid-data-tracker/#wastewater-surveillance' target = '_blank'>
                           covid.cdc.gov/covid-data-tracker/#wastewater-surveillance</a>
                           <br><br>"))
          
    
  ), # /Info tab
  
  ### FAQ tab -----
  tabItem(tabName = "FAQ_tab",
          
          # title = "Frequently asked questions",
          h3("Frequently asked questions"),
          p(HTML("<br>")),
          p(HTML("<b>What is wastewater surveillance?</b>"), style = "font-size: 16px"),
          p(HTML("People who are infected with SARS-CoV-2 (and potentially other pathogens) shed viral RNA (genetic material 
                           from the virus) in their feces. This RNA can be detected and measured in samples of community 
                           wastewater. Wastewater, also called sewage, can come from both residential use (toilets, 
                           showers, and sinks) as well as non-household sources like industrial use and rain. The process 
                           can be summarized as follows:
                           <ul>
                            <li>Wastewater from a sewershed (the community area served by a wastewater treatment utility) 
                                is collected as it flows into a treatment plant before treatment occurs (an influent 
                                sample).</li>
                            <li>The sample is transported to the Utah Public Health Laboratory (UPHL) for sample processing 
                                and testing.</li>
                            <li>UPHL transmits the raw laboratory data to the UWSS epidemiology team, who clean and analyze
                                it.</li>
                            <li>The data is made available to federal, state, and local public health partners via internal 
                                mechanisms, and the public via this dashboard.</li>
                           </ul>
                           <br>")),
          p(HTML("<b>What are some advantages of wastewater surveillance?</b>"), style = "font-size: 16px"),
          p(HTML("<ul>
                    <li>Wastewater surveillance can capture the presence of SARS-CoV-2 shed by people who have COVID-19, 
                        even if they don't have symptoms.</li>
                    <li>Wastewater surveillance data is often an early indicator that the number of people who have COVID-19 
                        in a community is increasing or decreasing.</li>
                    <li>Unlike most other types of public health surveillance, wastewater monitoring does not depend on 
                        the availability of individual testing, people having access to healthcare, or people seeking 
                        healthcare when sick (healthcare-seeking behavior).</li>
                    <li>Wastewater surveillance is a very efficient and cost-effective way to gather valuable 
                        public health data about communities.</li>
                 </ul>
                 <br>")),
          p(HTML("<b>What are some disadvantages of wastewater surveillance?</b>"), style = "font-size: 16px"),
          p(HTML("<ul>
                    <li>Wastewater surveillance will not capture data from homes that use a septic system or from facilities 
                        served by decentralized treatment systems, like some prisons, universities, or hospitals, that 
                        treat their own wastewater.</li>
                    <li>Very low levels of infection in communities may not be captured by wastewater surveillance. The 
                        lower limits of detection (the smallest number of people shedding the virus that can still 
                        be detected by current methods) for wastewater surveillance are not yet known.
                    <li>At this time, it is not possible to accurately and reliably predict the number of infected individuals 
                        in a community based solely on wastewater surveillance data.</li>
                    <li>We don't yet know enough about the many differences between sewersheds in infrastructure, population 
                        characteristics, industrial input, etc. to successfully account for them, meaning that direct 
                        comparison of data between sites is generally discouraged.</li>
                 </ul>
                 <br>")),
          p(HTML("<b>What is UWSS monitoring in wastewater?</b>"), style = "font-size: 16px"),
          p(HTML("Currently, UWSS is testing for SARS-CoV-2, the virus that causes COVID-19. In the future, we plan to expand 
                       testing to additional pathogens, including influenza A, influenza B, respiratory syncytial virus (RSV) A & B, 
                       mpox, and <i>Candida auris</i>.
                       <br><br>")),
          p(HTML("<b>How does genomic sequencing work?</b>"), style = "font-size: 16px"),
          p(HTML("Genomic sequencing is a method used to analyze the genetic material of an organism and can be used on viruses such as 
                 SARS-CoV-2. After sample collection and RNA extraction, the sample is loaded on to the sequencer which can identify the
                 sequence of base pairs in the organism’s genome. This is then compared to known sequences to detect mutations and identify 
                 specific variants.
                 <br><br>")),
          p(HTML("<b>What is a variant?</b>"), style = "font-size: 16px"),
          p(HTML("A variant is a version of a virus with a specific set of changes or mutations in its genetic material. While viruses 
                 constantly evolve, most of these changes do not have a major impact. However, some mutations can affect the severity of the
                 illness or how well vaccines work. We can monitor these variants to understand how the virus spreads in the community 
                 and identify variants that may require different public health actions. Variants are named using letters and numbers, 
                 as seen on the genomic data visualizations on our dashboard. 
                 <br><br>")),
          p(HTML("<b>Can SARS-CoV-2 variants of concern be detected in wastewater?</b>"), style = "font-size: 16px"),
          p(HTML("Yes, with the appropriate additional testing. UWSS has been performing whole genome sequencing of wastewater 
                       samples since October 2021.
                       <br><br>")),
          p(HTML("<b>What is a recombinant lineage?</b>"), style = "font-size: 16px"),
          p(HTML("A recombinant lineage occurs when 2 different variants combine their genetic material to create a new 
                 variant. This can happen when an individual is infected with multiple lineages of the virus at the same time. As 
                 the virus replicates, it may recombine genetic material between the variants which can then result in a new “recombinant”
                 virus. This virus can carry traits from both parent variants and can result in very rapid evolutionary change.
                 <br><br>")),
          p(HTML("<b>I have a question that isn't answered here.</b>"), style = "font-size: 16px"),
          p(HTML("If your question is related to sampling or data analysis, it may be answered in the 'Info and methods' 
                       tab. If not, don't hesitate to contact us at <a href = 'mailto: uwss@utah.gov'>uwss@utah.gov</a>!")),
          p(HTML("<br><br>"))
          
  ), # /FAQ tab
  
  
  ### Contact tab -----
  tabItem(tabName = "Contact_tab",
          
          # title = "Contact us",
          h3("Contact us"),
          p(HTML("For questions, comments, and concerns, email us at:")),
          p(HTML("<a href = 'mailto: uwss@utah.gov'>uwss@utah.gov</a>"), style = "font-size: 16px"),
          p(HTML("We'd love to hear from you!"))
          
  ) # /Contact tab
  
     ) # /tabitems
  ) # /dashboardBody
) # /dashboardPage



# SERVER -----

# Define server logic 
# server <- function(input, output, session) {
server <- function(input, output) {
  
## Load data -----
load("wastewaterdash.Rdata")
  
  # observe({
  #   url_input <- parseQueryString(session$clientData$url_search)
  #   if (!is.null(url_input[["site"]])) {
  #     updateTextInput(session, "selected_msd", value = url_input[["site"]])
  #   }
  # })
  
## Date selector -----
  output$datemenu <- renderUI({
    dateRangeInput(inputId = "date_input",
                   label = "Date range for plots",
                   start = max_date - 730,
                   end = max_date,
                   min = "2020-04-01",
                   max = Sys.Date(),
                   format = "mm/dd/yyyy",
                   separator = "to",
                   width = "225px")
  })
  
  
## Date selector reset -----
  observeEvent(input$reset_date, {
    reset("date_input")
  })
  
  
## Data & map prep -----
  
  # Round data
  plot_data <- plot_data %>%
    mutate(mgc_capita_day = round(mgc_capita_day, 1),
           daily_rate_100K = round(daily_rate_100K, 2))
  

  ww_min_date <- min(plot_data$date)
  ww_max_date <- max(plot_data$date + 2)
  
  
  bounds <- sf::st_bbox(ut_poly)
  
  
  base_map <- leaflet(options = leafletOptions(preferCanvas = T,
                                               dragging = T)) %>%
    addProviderTiles("CartoDB.VoyagerLabelsUnder",
                     group = "Cartog",
                     options = providerTileOptions(updateWhenZooming = F,
                                                   updateWhenIdle = T)) %>%
    addMapPane("ut_poly", zIndex = 417) %>%
    addMapPane("service_areas", zIndex = 418) %>%
    addMapPane("highlight", zIndex = 419) %>%
    addMapPane("markers", zIndex = 420) %>%
    addPolygons(data = ut_poly,
                color = "darkgrey",
                fillColor = "transparent",
                options = pathOptions(pane = "ut_poly"),
                group = "ut_poly") %>%
    fitBounds(bounds[[1]], bounds[[2]], bounds[[3]], bounds[[4]]) %>%
    setView(lat = 39.5000, lng = -111.4000, zoom = 07) %>%
    addMapResetButton()
  
  reactive_objects = reactiveValues()
  

## Map -----

### Icon list -----
# Create an icon list from custom map icons
map_icons <- iconList(ex_elev_inc = makeIcon(iconUrl = "map_icons/ex_elev_inc.png",
                                             iconWidth = 20,
                                             iconHeight = 15),
                      ex_elev_dec = makeIcon(iconUrl = "map_icons/ex_elev_dec.png",
                                             iconWidth = 20,
                                             iconHeight = 15),
                      ex_elev_plat = makeIcon(iconUrl = "map_icons/ex_elev_plat.png",
                                              iconWidth = 16,
                                              iconHeight = 16),
                      ex_elev_none = makeIcon(iconUrl = "map_icons/ex_elev_none.png",
                                              iconWidth = 19,
                                              iconHeight = 19),
                      v_elev_inc = makeIcon(iconUrl = "map_icons/v_elev_inc.png",
                                            iconWidth = 20,
                                            iconHeight = 15),
                      v_elev_dec = makeIcon(iconUrl = "map_icons/v_elev_dec.png",
                                            iconWidth = 20,
                                            iconHeight = 15),
                      v_elev_plat = makeIcon(iconUrl = "map_icons/v_elev_plat.png",
                                             iconWidth = 16,
                                             iconHeight = 16),
                      v_elev_none = makeIcon(iconUrl = "map_icons/v_elev_none.png",
                                             iconWidth = 19,
                                             iconHeight = 19),
                      elev_inc = makeIcon(iconUrl = "map_icons/elev_inc.png",
                                          iconWidth = 20,
                                          iconHeight = 15),
                      elev_dec = makeIcon(iconUrl = "map_icons/elev_dec.png",
                                          iconWidth = 20,
                                          iconHeight = 15),
                      elev_plat = makeIcon(iconUrl = "map_icons/elev_plat.png",
                                           iconWidth = 16,
                                           iconHeight = 16),
                      elev_none = makeIcon(iconUrl = "map_icons/elev_none.png",
                                           iconWidth = 19,
                                           iconHeight = 19),
                      watch_inc = makeIcon(iconUrl = "map_icons/watch_inc.png",
                                           iconWidth = 20,
                                           iconHeight = 15),
                      watch_dec = makeIcon(iconUrl = "map_icons/watch_dec.png",
                                           iconWidth = 20,
                                           iconHeight = 15),
                      watch_plat = makeIcon(iconUrl = "map_icons/watch_plat.png",
                                            iconWidth = 16,
                                            iconHeight = 16),
                      watch_none = makeIcon(iconUrl = "map_icons/watch_none.png",
                                            iconWidth = 19,
                                            iconHeight = 19),
                      low_inc = makeIcon(iconUrl = "map_icons/low_inc.png",
                                         iconWidth = 20,
                                         iconHeight = 15),
                      low_dec = makeIcon(iconUrl = "map_icons/low_dec.png",
                                         iconWidth = 20,
                                         iconHeight = 15),
                      low_plat = makeIcon(iconUrl = "map_icons/low_plat.png",
                                          iconWidth = 16,
                                          iconHeight = 16),
                      low_none = makeIcon(iconUrl = "map_icons/low_none.png",
                                          iconWidth = 19,
                                          iconHeight = 19),
                      v_low_inc = makeIcon(iconUrl = "map_icons/v_low_inc.png",
                                           iconWidth = 20,
                                           iconHeight = 15),
                      v_low_dec = makeIcon(iconUrl = "map_icons/v_low_dec.png",
                                           iconWidth = 20,
                                           iconHeight = 15),
                      v_low_plat = makeIcon(iconUrl = "map_icons/v_low_plat.png",
                                            iconWidth = 16,
                                            iconHeight = 16),
                      v_low_none = makeIcon(iconUrl = "map_icons/v_low_none.png",
                                            iconWidth = 19,
                                            iconHeight = 19),
                      insuf_inc = makeIcon(iconUrl = "map_icons/insuf_inc.png",
                                           iconWidth = 20,
                                           iconHeight = 15),
                      insuf_dec = makeIcon(iconUrl = "map_icons/insuf_dec.png",
                                           iconWidth = 20,
                                           iconHeight = 15),
                      insuf_plat = makeIcon(iconUrl = "map_icons/insuf_plat.png",
                                            iconWidth = 16,
                                            iconHeight = 16),
                      insuf_none = makeIcon(iconUrl = "map_icons/insuf_none.png",
                                            iconWidth = 19,
                                            iconHeight = 19),
                      legacy = makeIcon(iconUrl = "map_icons/legacy.png",
                                        iconWidth = 14,
                                        iconHeight = 14)
)


sewershed_centroids <- sewershed_centroids %>%
  mutate(icon = case_when(quant == 99 & trend == "Increasing" ~ "insuf_inc",
                          quant == 99 & trend == "Decreasing" ~ "insuf_dec",
                          quant == 99 & trend == "Plateau/Indeterminate" ~ "insuf_plat",
                          quant == 99 & trend == "Insufficient data" ~ "insuf_none",
                          quant == 6 & trend == "Increasing" ~ "ex_elev_inc",
                          quant == 6 & trend == "Decreasing" ~ "ex_elev_dec",
                          quant == 6 & trend == "Plateau/Indeterminate" ~ "ex_elev_plat",
                          quant == 6 & trend == "Insufficient data" ~ "ex_elev_none",
                          quant == 5 & trend == "Increasing" ~ "v_elev_inc",
                          quant == 5 & trend == "Decreasing" ~ "v_elev_dec",
                          quant == 5 & trend == "Plateau/Indeterminate" ~ "v_elev_plat",
                          quant == 5 & trend == "Insufficient data" ~ "v_elev_none",
                          quant == 4 & trend == "Increasing" ~ "elev_inc",
                          quant == 4 & trend == "Decreasing" ~ "elev_dec",
                          quant == 4 & trend == "Plateau/Indeterminate" ~ "elev_plat",
                          quant == 4 & trend == "Insufficient data" ~ "elev_none",
                          quant == 3 & trend == "Increasing" ~ "watch_inc",
                          quant == 3 & trend == "Decreasing" ~ "watch_dec",
                          quant == 3 & trend == "Plateau/Indeterminate" ~ "watch_plat",
                          quant == 3 & trend == "Insufficient data" ~ "watch_none",
                          quant == 2 & trend == "Increasing" ~ "low_inc",
                          quant == 2 & trend == "Decreasing" ~ "low_dec",
                          quant == 2 & trend == "Plateau/Indeterminate" ~ "low_plat",
                          quant == 2 & trend == "Insufficient data" ~ "low_none",
                          quant == 1 & trend == "Increasing" ~ "v_low_inc",
                          quant == 1 & trend == "Decreasing" ~ "v_low_dec",
                          quant == 1 & trend == "Plateau/Indeterminate" ~ "v_low_plat",
                          quant == 1 & trend == "Insufficient data" ~ "v_low_none",
                          trend == "Legacy" ~ "legacy")) %>%
  mutate(pct_change = as.character(round_half_up(pct_change, 1))) %>%
  mutate(pct_change = case_when(is.na(pct_change) ~ "No trend",
                                TRUE ~ paste0(pct_change, "%"))) %>%
  mutate(level6 = case_when(quant == 99 ~ "Insufficient data",
                            quant == 6 ~ "Extremely elevated",
                            quant == 5 ~ "Very elevated",
                            quant == 4 ~ "Elevated",
                            quant == 3 ~ "Watch",
                            quant == 2 ~ "Low",
                            quant == 1 ~ "Very low",
                            is.na(quant) ~ "Legacy")) %>%
  mutate(quant = case_when(!is.na(quant) ~ as.character(quant),
                           is.na(quant) ~ "N/A")) %>%
  mutate(trend = case_when(trend == "Plateau/Indeterminate" ~ "Plateau/indeterminate", 
                           TRUE ~ trend))


### Legend -----
map_legend <- "<font size = '2'>
               <b>Concentration</b></br>
               <img src = 'ex_elevated.png' height = '25' vspace = '5'> Extremely elevated</br>
               <img src = 'v_elevated.png' height = '25' vspace = '5'> Very elevated</br>
               <img src = 'elevated.png' height = '25' vspace = '5'> Elevated</br>
               <img src = 'watch.png' height = '25' vspace = '5'> Watch</br>
               <img src = 'low2.png' height = '25' vspace = '5'> Low</br>
               <img src = 'v_low.png' height = '25' vspace = '5'> Very low</br>
               <img src = 'insufficient.png' height = '25' vspace = '5'> Insufficient historical data</br></br>
               <b>Trend</b></br>
               <img src = 'inc_empty.png' height = '25' vspace = '5'> Increasing</br>
               <img src = 'plat_empty.png' height = '25' vspace = '5'> Plateau/indeterminate</br>
               <img src = 'dec_empty.png' height = '25' vspace = '5'> Decreasing</br>
               <img src = 'none_empty.png' height = '25' vspace = '5'> Insufficient recent data</br></br>
               <b>Other</b></br>
               <img src = 'legacy.png' height = '25' vspace = '5'> Legacy site
               </font>
              "


output$combo_map = renderLeaflet({
  base_map %>%
    addCircles(data = sewershed_centroids,
               label = ~msd_shrtnm,
               fill = F,
               stroke = F,
               group = "search") %>%
    addMarkers(data = subset(sewershed_centroids, trend != "Legacy"),
               layerId = ~msd_name,
               icon = ~map_icons[icon],
               label = ~msd_shrtnm,
               options = pathOptions(pane = "markers"),
               labelOptions = labelOptions(noHide = F,
                                           style = list("font-size" = "12px"))) %>%
    addMarkers(data = subset(sewershed_centroids, trend == "Legacy"),
               layerId = ~msd_name,
               icon = ~map_icons[icon],
               label = ~msd_shrtnm,
               group = "Show legacy sites",
               options = pathOptions(pane = "markers"),
               labelOptions = labelOptions(noHide = F,
                                           style = list("font-size" = "12px"))) %>%
    addPolygons(data = county,
                fillColor = "#abede5",
                fillOpacity = 0.2,
                color = "#23A595",
                weight = 2,
                group = "County borders",
                label = ~paste(name, "County"),
                labelOptions = labelOptions(noHide = F,
                                            textsize = "12px",
                                            direction = "center")) %>%
    addLabelOnlyMarkers(data = county_centroids,
                        group = "County names",
                        label = ~paste(name, "County"),
                        labelOptions = labelOptions(noHide = T,
                                                    textsize = "12px",
                                                    direction = "center")) %>%
    #This is where the problem is
    addPolygons(data = lhd,
                fillColor = "#a5a8f3",
                fillOpacity = 0.2,
                color = "#181eb4",
                weight = 2,
                group = "LHD borders",
                label = ~paste(LHD, "LHD"),
                labelOptions = labelOptions(noHide = F,
                                            textsize = "12px",
                                            direction = "center")) %>%
    addLabelOnlyMarkers(data = lhd_centroids,
                        group = "LHD names",
                        label = ~LHD,
                        labelOptions = labelOptions(noHide = T,
                                                    textsize = "12px",
                                                    direction = "center")) %>%
    addControl(html = map_legend, position = "topright") %>%
    addLayersControl(overlayGroups = c("Show legacy sites", "County borders", "County names", "LHD borders", "LHD names"),
                     position = "bottomleft",
                     options = layersControlOptions(collapsed = FALSE)) %>%
    hideGroup(c("Show legacy sites", "County borders", "County names", "LHD borders", "LHD names")) %>%
    addSearchFeatures(targetGroups = "search",
                      options = searchFeaturesOptions(zoom = 11,
                                                      hideMarkerOnCollapse = T))
})


### map marker click ----

selected_msd = eventReactive(input$combo_map_marker_click, {
  input$combo_map_marker_click$id
})


observeEvent(selected_msd(), {
  sel_data = subset(plot_data, msd_name %in% selected_msd())
  reactive_objects$sel_data = sel_data
  sel_poly = subset(sewersheds_dis, msd_name %in% selected_msd())
  bounds = sf::st_bbox(sel_poly)
  
  
  leafletProxy("combo_map") %>%
    clearGroup(group = 'highlight') %>%
    clearGroup("Service areas") %>%
    addCircleMarkers(data = subset(sewershed_centroids,
                                   msd_name %in% selected_msd()),
                     group = 'highlight',
                     options = pathOptions(pane = "highlight"),
                     color = ww_colors[[6]][[2]],
                     radius = 15) %>%
    addPolygons(data = sel_poly,
                fillColor = ww_colors[[6]][[1]],
                color = ww_colors[[6]][[2]],
                weight = 1,
                opacity = 1,
                group = "Service areas",
                options = pathOptions(pane = "service_areas")) %>%
    flyToBounds(bounds[[1]], bounds[[2]], bounds[[3]], bounds[[4]])
    
})


### Facility name valueBox ----

output$msd_name_valbox <- renderValueBox({
  pop <- subset(ww_populations, msd_name %in% selected_msd())$population[1]
  
  if(length(selected_msd())){
  
  valueBox(
    value = tags$p(reactive_objects$sel_data$msd_shrtnm[1],
                   style = "font-size: 40%;"),
    subtitle = tags$p(paste("Estimated population served:", 
                     prettyNum(pop, big.mark = ",")),
                     style = "font-size: 90%;"),
    icon = tags$i(class = "fas fa-map-marker-alt",
                  style = "font-size: 60%"),
    color = "olive")
  }
})


### 6-tier level valueBox -----
output$msd_level6_valbox <- renderValueBox({
  level6 <- subset(sewershed_centroids, msd_name %in% selected_msd())$level6[1]
  quant <- subset(sewershed_centroids, msd_name %in% selected_msd())$quant[1]
  last_result <- subset(sewershed_centroids, msd_name %in% selected_msd())$last_result[1]
  valueBox(
    value = tags$p(paste0("Concentration: ", level6),
                   style = "font-size: 40%"), 
    subtitle = tags$p(paste0("Most recent sample: ", last_result, " MGC/person/day"),
                      style = "font-size: 90%;"),
    color = if(level6 %in% c("Extremely elevated", "Very elevated", "Elevated")) "red" else
      if(level6 == "Watch") "orange" else
        if(level6 %in% c("Very low", "Low")) "teal" else
          if(level6 == "Insufficient data") "black" else
            if(level6 == "Legacy") "black")
})


### Trend valueBox ----
output$pct_change_valbox <- renderValueBox({
  trend <- subset(sewershed_centroids, msd_name %in% selected_msd())$trend[1]
  pct_change <- subset(sewershed_centroids, msd_name %in% selected_msd())$pct_change[1]
  trend_icon <- if(trend == "Increasing") "fas fa-arrow-up" else
    if(trend == "Plateau/indeterminate") "fas fa-square" else
      if(trend == "Decreasing") "fas fa-arrow-down" else
        if(trend == "Insufficient recent data") "fas fa-ban" else
          if(trend == "Legacy") "fas fa-square"
  valueBox(
    value = tags$p(paste0("Trend: ", trend),
                   style = "font-size: 40%;"),
    subtitle = tags$p(paste("13-day percent change:", pct_change),
                      style = "font-size: 90%;"),
    icon = tags$i(class = trend_icon,
                  style = "font-size: 60%"),
    color = "purple")
})

### Genomic valueBox ----
output$genomic_valbox <- renderValueBox({
  
  #Get the max variant with it's information
  max_vars <- data_seq_sumLin %>%
    filter(msd_name %in% selected_msd()) %>%
    group_by(msd_name, collection_date, summarized_lineage) %>%
    summarise(max_variant = max(percentage)) 
  
  maxDate <- max(max_vars$collection_date)
  
  max_variant_info <- max_vars %>%
    filter(collection_date == maxDate) %>%
    arrange(desc(max_variant))
  
  max_summarized_lineage <- max_variant_info$summarized_lineage[1]
  max_lineage_abundance <- max_variant_info$max_variant[1]
  
  
  #Create valuebox for legacy sites
  if(length(selected_msd())){
    if(selected_msd() %in% legacy) {
      valueBox(
        value = tags$p(paste0("Dominant lineage: ", "No data"), #Set legacy to "no data"
                       style = "font-size: 40%;"),
        subtitle = tags$p(paste0("Relative abundance: ",
                                 "No data"), #Set legacy to "no data"
                          style = "font-size: 90%;"),
        icon = tags$i(class = "fas fa-dna",
                      style = "font-size: 60%"),
        color = "light-blue")
    }else{
      #If not a legacy site, create valuebox with max variant info
      valueBox(
        value = tags$p(paste0("Dominant lineage: ", max_summarized_lineage),
                       style = "font-size: 40%;"),
        subtitle = tags$p(paste0("Relative abundance: ",
                                 prettyNum(round_half_up(max_lineage_abundance, 1), big.mark = ","), "%"),
                          style = "font-size: 90%;"),
        icon = tags$i(class = "fas fa-dna",
                      style = "font-size: 60%"),
        color = "light-blue")
      
    }
    
  }
})


### Summary table ----- 

#Serverside data processing

#create a clean dataframe with the information in sewershed_centroids
sewershed_centroids_df <- as.data.frame(sewershed_centroids)

#Pull facility ID from csv for later join
fac_name_id <- read_csv("csv_files/fac_name_id.csv")
fac_county_LHD <- read_csv("csv_files/Facility_LHD_County.csv")

# Assign trends and names of columns and keep meaningful columns for table
sewershed_centroids_df %>%
  select(msd_name, msd_shrtnm, trend, quant) %>%
  mutate(Concentration = case_when(quant == 1 ~ "Very low",
                                   quant == 2 ~ "Low",
                                   quant == 3 ~ "Watch",
                                   quant == 4 ~ "Elevated",
                                   quant == 5 ~ "Very elevated",
                                   quant == 6 ~ "Extremely elevated",
                                   quant == 99 ~ "Insufficient historical data")) %>%
  right_join(fac_name_id, by = "msd_name") %>%
  right_join(fac_county_LHD, by = "msd_name") %>%
  filter(msd_name %notin% c("(MAGWWTP) Magna WWTP")) %>% #Will need to fix this
  arrange(summary_id) %>%
  rename(Facility = msd_name,
         Trend = trend,
         `Facility Shortname` = msd_shrtnm) %>%
  select(-quant) -> sum_df

output$facilityTable = DT::renderDataTable({
  
  #Assign icons to the trends for presentation in final table
  sum_df <- sum_df %>%
    rename(TrendTemp = Trend) %>%
    mutate(Trend = case_when(TrendTemp == "Increasing" ~ paste(TrendTemp,
                                                               as.character(shiny::icon("arrow-up", lib = "glyphicon"))),
                             TrendTemp == "Decreasing" ~ paste(TrendTemp,
                                                               as.character(shiny::icon("arrow-down", lib = "glyphicon"))),
                             TrendTemp == "Plateau/indeterminate" ~ paste(TrendTemp,
                                                                          as.character(shiny::icon("minus", lib = "glyphicon"))),
                             TrendTemp == "Insufficient data" ~ paste(TrendTemp,
                                                                      as.character(shiny::icon("remove", lib = "glyphicon"))))) %>%
    
    select(`Facility Shortname`, County, LHD, Concentration, Trend) %>%
    rename(Facility = `Facility Shortname`)
  
  #Make sure that sum_df is in fact a dataframe
  sum_df <- as.data.frame(sum_df)
  
  #Casts datatable as an html object, reads the html object and render UI for display
  DT::datatable(sum_df,rownames = FALSE, escape = FALSE, selection = "single", #server = TRUE,
                options = list(pageLength = length(sum_df$Facility),
                               #escape=FALSE,
                               searching = FALSE,
                               selection = 'single',
                               mode = "single",
                               server = TRUE,
                               dom = 'ft',
                               columnDefs = list(list(className = 'dt-center', targets = 0:4)),
                               initComplete = JS(
                                 "function(settings, json) {",
                                 "$('body').css({'font-family': 'Open Sans'});",
                                 "}"
                               ))) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Very low", "#2c7bb6"),
                color = styleEqual("Very low", "white")) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Low", "#abd9e9")) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Watch", "#fdae61")) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Elevated", "#db696b")) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Very elevated", "#d81d20"),
                color = styleEqual("Very elevated", "white")) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Extremely elevated", "#8a0032"),
                color = styleEqual("Extremely elevated", "white")) %>%
    formatStyle('Concentration',
                backgroundColor = styleEqual("Insufficient historical data", "#a6a6a5"))
  
})


#### Clickable Table -----

# try_map <- observeEvent(input$combo_map_marker_click,{
#                         input$combo_map_marker_click$id})
# 
# try_table <- observeEvent(input$facilityTable_rows_selected,
#                           sum_df$Facility[input$facilityTable_rows_selected])

# print the selected indices
output$x4 = renderPrint({
  # if(length(input$combo_map_marker_click)){
  #   s = input$combo_map_marker_click$id
  # }else if(length(input$facilityTable_rows_selected)){
  #   s = sum_df$Facility[input$facilityTable_rows_selected]
  # }
  
  # s = selected_msd()
  
  s = selected_map()
  
  #s = sum_df$Facility[input$facilityTable_rows_selected]
  if (length(s)) {
    cat('These rows were selected:\n\n')
    #cat(s, sep = ', ')
    s
  }
})

# data_filtered<-reactive({
#   if(length(sum_df$Facility[input$facilityTable_rows_selected])) {
#     data %>%
#       filter(facility %in% input$e2)
#   }else if (is.null(input$abTable_rows_selected) & !is.null(input$dropoff_rows_selected)){
#     data %>%
#       filter(facility %in% dropoffs$facility[input$dropoff_rows_selected])
#   }else{
#     data %>%
#       filter(facility %in% aberrationsLastWeek$facility[input$abTable_rows_selected])
#   }
# 
# })

# print the selected indices
output$x4 = renderPrint({
  # if(length(input$combo_map_marker_click)){
  #   s = input$combo_map_marker_click$id
  # }else if(length(input$facilityTable_rows_selected)){
  #   s = sum_df$Facility[input$facilityTable_rows_selected]
  # }
     
 # s = selected_msd()
    
  s = selected_map()
  
  #s = sum_df$Facility[input$facilityTable_rows_selected]
  if (length(s)) {
    cat('These rows were selected:\n\n')
    #cat(s, sep = ', ')
    s
  }
})

# data_filtered<-reactive({
#   if(length(sum_df$Facility[input$facilityTable_rows_selected])) {
#     data %>%
#       filter(facility %in% input$e2)
#   }else if (is.null(input$abTable_rows_selected) & !is.null(input$dropoff_rows_selected)){
#     data %>%
#       filter(facility %in% dropoffs$facility[input$dropoff_rows_selected])
#   }else{
#     data %>%
#       filter(facility %in% aberrationsLastWeek$facility[input$abTable_rows_selected])
#   }
# 
# })


### Charts -----
output$results_subplot = renderPlotly({
  
  # Filter by input dates
  start_date <- input$date_input[1]
  end_date <- input$date_input[2]
  
  # plot_data <- plot_data %>%
  #   filter(date >= start_date & date <= end_date)
  
  req(reactive_objects$sel_data)
  
  # Conditional for only filtering graph data by date input if the site is non-legacy
  if(reactive_objects$sel_data$legacy_site[1] == "N") {
  res_plot_data = reactive_objects$sel_data %>%
    filter(date >= start_date & date <= end_date)
  }
  
  else{
    res_plot_data <- reactive_objects$sel_data
  }
  
  max_sewage = max(res_plot_data$mgc_capita_day, na.rm = T)
  max_cases = max(res_plot_data$daily_rate_100K, na.rm = T)

  
  q_name <- res_plot_data$msd_shrtnm
  q_date <- res_plot_data$date
  q_quant <- res_plot_data$quant_cat
  
  min_date = min(res_plot_data$date)
  max_date = max(res_plot_data$date + 4)
  
  # Add lines for important dates to the wastewater data graph
  byVal = (max_sewage+40)/length(res_plot_data$msd_shrtnm)
  
  res_plot_data <- res_plot_data %>%
    mutate(dd_PCR_date = "2024-02-28") %>%
    mutate(resp_panel_date = "2024-11-14") %>%
    mutate(counts = seq(byVal, max_sewage+40, by = byVal))
  
  
  shared_data = highlight_key(res_plot_data)
  
  
  #### Wastewater chart -----
  vline_data <- data.frame("X" = "2024-02-12", "Y" = 0:1000)
  
  sew_ts = plot_ly(shared_data) %>%
    add_trace(type = "scatter",
              x = ~date,
              y = ~mgc_capita_day,
              text = ~msd_shrtnm,
              mode = 'lines+markers',
              fill = "tozeroy",
              fillcolor = "rgba(169, 90, 161, 0.4)'",
              showlegend = F,
              marker = list(color = ww_colors[[6]][[1]],
                            size = 4,
                            line = list(color = ww_colors[[6]][[2]],
                                        width = 2)),
              line = list(color = ww_colors[[6]][[2]],
                          width = 2),
              connectgaps = T,
              name = "Selected sewershed",
              hovertemplate = paste("<b>Wastewater data</b>",
                                    "<br>%{text}",
                                    "<br>%{x}",
                                    "<br>MGC/person/day: %{y}<extra></extra>")) %>%
    add_trace(
      x = ~dd_PCR_date,
      y = ~counts,
      type = 'scatter',
      mode = 'lines',
      connectgaps = T,
      showlegend = F,
      line = list(color = "#bfbfbf", width = 2, dash = "dash"),
      #marker = list(color = "#D3D3D3", size = 0.00001),
      hovertemplate = paste("<b>Method change</b>",
                            "<br>Change from qPCR to ddPCR on 2024-02-28. <br>Please see 'Info and methods' tab for more details.<extra></extra>")) %>%
    add_trace(
      x = ~resp_panel_date,
      y = ~counts,
      type = 'scatter',
      mode = 'lines',
      connectgaps = T,
      showlegend = F,
      line = list(color = "#bfbfbf", width = 2, dash = "dot"),
      #marker = list(color = "#D3D3D3", size = 0.00001),
      hovertemplate = paste("<b>Method change</b>",
                            "<br>Change from two combined gene targets to a single gene target. <br>Please see 'Info and methods' tab for more details.<extra></extra>")) %>%
    layout(legend = list(x = 1,
                         y = -0.1,
                         xanchor = "right",
                         yanchor = "top",
                         orientation = "h"),
           xaxis = list(title = "",
                        type = "date",
                        showline = TRUE,
                        range = c(min_date, max_date)),
           yaxis = list(title = list(text = 'Millions of gene copies/person/day',
                                     font = list(size = 12)),
                        zeroline = TRUE),
           annotations = list(x = -0.01,
                              y = 1.15,
                              text = "SARS-CoV-2 wastewater surveillance data",
                              showarrow = F,
                              xref = 'paper',
                              yref = 'paper',
                              xanchor = 'left',
                              yanchor = 'auto',
                              xshift = 0,
                              yshift = 0,
                              font = list(size = 14,
                                          color = "#444444"))) %>%
    plotly::config(displaylogo = FALSE,
                   modeBarButtonsToRemove = c('sendDataToCloud',
                                              'hoverClosestCartesian',
                                              'hoverCompareCartesian',
                                              'lasso2d',
                                              'select2d'))
  
    sew_ts = sew_ts %>%
      layout(yaxis = list(range = c((0 - max_sewage * 0.1), max_sewage * 1.1)))
  
  
  ### Case data chart -----
  case_ts = plot_ly(shared_data) %>%
    add_trace(type = "scatter",
              x = ~date,
              y = ~daily_rate_100K,
              text = ~paste0("<b>Case data</b>", "<br>",
                             `msd_shrtnm`, "<br>",
                             `date`, "<br>",
                             "Daily case rate: ", `daily_rate_100K`, "<br>",
                             "Suppressed: ", `suppressed`),
              mode = "lines",
              fill = "tozeroy",
              fillcolor = "rgba(1, 102, 153, 0.4)",
              connectgaps = TRUE,
              showlegend = F,
              visible = T,
              line = list(color = "#016699",
                          width = 2),
              name = "Selected sewershed",
              hovertemplate = "%{text}<extra></extra>") %>%
    layout(legend = list(x = 1,
                         y = -0.1,
                         xanchor = "right",
                         yanchor = "top",
                         orientation = "h"),
           xaxis = list(title = "Date",
                        type = "date",
                        showline = TRUE,
                        range = c(min_date, max_date)),
           yaxis = list(title = list(text = 'Cases / 100,000',
                                     font = list(size = 12)),
                        zeroline = TRUE),
           annotations = list(x = -0.01,
                              y = 1.10,
                              text = "Case rate per 100,000 (rates based on small case counts from 1-4 are suppressed)",
                              showarrow = F,
                              xref = 'paper',
                              yref = 'paper',
                              xanchor = 'left',
                              yanchor = 'auto',
                              xshift = 0,
                              yshift = 0,
                              font = list(size = 14,
                                          color = "#444444"))) %>%
    plotly::config(displaylogo = FALSE,
                   modeBarButtonsToRemove = c('sendDataToCloud',
                                              'hoverClosestCartesian',
                                              'hoverCompareCartesian',
                                              'lasso2d',
                                              'select2d'))
  

    case_ts = case_ts %>%
      layout(yaxis = list(range = c((0 - max_cases * 0.1), max_cases * 1.1)))
  
  
  ### Quantile bar chart -----
  quant_chart <- plot_ly(shared_data) %>%
    add_trace(type = "bar",
              x = ~date,
              y = ~quant_n,
              showlegend = F,
              #text = ~quant3,
              marker = list(color = ~quant_color),
              hoverinfo = "text",
              hovertext = paste(q_name,
                                "<br>", q_date,
                                "<br>", q_quant)) %>%
    layout(bargap = 0,
           xaxis = list(title = "",
                        type = "date",
                        showline = F,
                        range = c(min_date, max_date)),
           yaxis = list(title = "",
                        showline = F,
                        showticklabels = F),
           annotations = list(x = -0.01,
                              y = 2.0,
                              text = "Historical concentration categories",
                              showarrow = F,
                              xref = 'paper',
                              yref = 'paper',
                              xanchor = 'left',
                              yanchor = 'auto',
                              xshift = 0,
                              yshift = 0,
                              font = list(size = 14,
                                          color = "#444444")))
  
    
  ### Genomic bar chart -----
    
  if(selected_msd() %notin% legacy){
    data_seq_sumLinAll <- data_seq_sumLin %>%
      filter(msd_name %in% selected_msd()) %>%
      group_by(collection_date) %>%
      mutate(abunSumAll = sum(sum_abundance))
    
    #This allows to get the max genomic date to fill only true data (no future values)
    max_coll_date_gen <- max(data_seq_sumLinAll$collection_date)
    
    
    data_seq_sumLinAll_1 <- data_seq_sumLinAll %>%
      group_by(collection_date, summarized_lineage) %>%
      mutate(abunSumLinAll = sum(sum_abundance))%>%
      mutate(percentageAll = (abunSumLinAll/abunSumAll)*100) %>%
      distinct(summarized_lineage, collection_date, percentageAll) %>%
      ungroup() %>%
      pivot_wider(names_from = summarized_lineage, values_from = percentageAll) %>%
      arrange(collection_date)
    
    
    data_seq_sumLinAll_1[is.na(data_seq_sumLinAll_1)] <- 0
    
    
    all_abun <- data_seq_sumLinAll_1 %>%
      complete(collection_date = seq.Date(as.Date("2021-09-24"), as.Date(max_coll_date_gen), by = "day")) %>%
      fill(everything(), .direction = "down") %>%
      pivot_longer(cols = -collection_date, values_to = "percentageAll", names_to = "summarized_lineage")
    
    all_abun <- all_abun %>%
      filter(collection_date >= start_date & collection_date <= end_date)
    
    marker_style <- list(line = list(width = 0,
                                     color = 'rgb(0, 0, 0)'))
    
    gen_data <- plot_ly(all_abun,
                        x = ~collection_date,
                        y = ~percentageAll,
                        type = 'bar',
                        color = ~summarized_lineage,
                        colors = lineageColors,
                        marker = marker_style,
                        # text = ~summarized_lineage,
                        text = ~paste0("<b>Wastewater sequence data</b>", "<br>",
                                       # `msd_shrtnm`, "<br>",
                                       `collection_date`, "<br>",
                                       "Lineage: ", `summarized_lineage`, "<br>",
                                       "Percent of sample: ", round_half_up(percentageAll, 1), "%"),
                        textposition = "none",
                        hovertemplate = "%{text}<extra></extra>") %>%
      layout(xaxis = list(hoverformat = c(~percentageAll, ~collection_date))) %>%
      layout(yaxis = list(title = list(text = 'Variant abundance (%)',
                                       font = list(size = 12)),
                          range = c(0, 100)),
             annotations = list(x = -0.01,
                                y = 1.05,
                                text = "Sequencing data",
                                showarrow = F,
                                xref = 'paper',
                                yref = 'paper',
                                xanchor = 'left',
                                yanchor = 'auto',
                                xshift = 0,
                                yshift = 0,
                                font = list(size = 14,
                                            color = "#444444")),
             barmode = "stack",
             legend = list(traceorder = 'normal',
                           orientation = 'h', # show entries horizontally
                           xanchor = "center", # use center of legend as anchor
                           x = 0.5),  # put legend in center of x-axis
             xaxis = list(title = 'Collection date'))
  }
  # 
  ### Combined subplot -----
  if(selected_msd() %in% legacy){
    subplot(nrows = 3,
            sew_ts,
            quant_chart,
            case_ts,
            heights = c(0.353, 0.080, 0.214),
            margin = 0.03,
            titleY = TRUE,
            shareX = TRUE,
            titleX = TRUE) %>%
      highlight(on = NULL) %>%
      layout(xaxis = list(showticklabels = T),
             margin = list(b = 50,
                           l = 50))
  }else{
      subplot(nrows = 4,
              sew_ts,
              quant_chart,
              case_ts,
              gen_data,
              heights = c(0.353, 0.080, 0.214, 0.313),
              margin = 0.03,
              titleY = TRUE,
              shareX = TRUE,
              titleX = TRUE) %>%
        highlight(on = NULL) %>%
        layout(xaxis = list(showticklabels = T),
               margin = list(b = 50,
                             l = 50))
  }
}) # /site-specific charts

  

  ### Heatmap, statewide -----
  output$heatmap_statewide <- renderPlotly({
    
    # Filter by input dates
    start_date <- input$date_input[1]
    end_date <- input$date_input[2]
    
    heatmap_data <- heatmap_data %>%
      filter(date >= start_date & date <= end_date)

  # Alternate numbering for inclusion of an "Insufficient data" category. This is needed for proper ordering in catmaply
  # heatmap_statewide_colors_6 <- c("1" = "#a6a6a5",
  #                                 "2" = "#2c7bb6",
  #                                 "3" = "#abd9e9",
  #                                 "4" = "#fdae61",
  #                                 "5" = "#db696b",
  #                                 "6" = "#d81d20",
  #                                 "7" = "#8a0032")
    
    
    heatmap_statewide_colors_6 <- c("1" = "#2c7bb6",
                                    "2" = "#abd9e9",
                                    "3" = "#fdae61",
                                    "4" = "#db696b",
                                    "5" = "#d81d20",
                                    "6" = "#8a0032")


  # max_step <- length(heatmap_data$date) / length(unique(heatmap_data$msd_name))
  
  
  catmaply(heatmap_data,
           x = date,
           y = msd_shrtnm,
           y_order = order,
           z = quant,
           x_side = "bottom",
           x_tickangle = 45,
           x_range = (length(heatmap_data$date) / length(unique(heatmap_data$msd_name))),
           rangeslider = F,
           legend_interactive = F,
           tickformat = "%b %Y",
           legend_col = quant_cat,
           hover_template = paste0(msd_shrtnm, "<br>",
                                   date, "<br>",
                                   quant_cat,
                                   "<extra></extra>"),
           color_palette = heatmap_statewide_colors_6) %>%
    layout(height = 650,
           xaxis = list(tickangle = -45,
                        dtick = "M3"))
  
  
  }) # /Heatmap, statewide



  # Genomic stacked bargraph, statewide ----
  output$genomic_statewide <- renderPlotly({
    
    data_seq_sumLinAll <- data_seq_sumLin %>%
      group_by(collection_date) %>%
      mutate(abunSumAll = sum(sum_abundance))
    
    #This allows to get the max genomic date to fill only true data (no future values)
    max_coll_date_gen <- max(data_seq_sumLinAll$collection_date)
    
    
    data_seq_sumLinAll_1 <- data_seq_sumLinAll %>%
      group_by(collection_date, summarized_lineage) %>%
      mutate(abunSumLinAll = sum(sum_abundance))%>%
      mutate(percentageAll = (abunSumLinAll/abunSumAll)*100) %>%
      distinct(summarized_lineage, collection_date, percentageAll) %>%
      ungroup() %>%
      pivot_wider(names_from = summarized_lineage, values_from = percentageAll) %>%
      arrange(collection_date)
    
    
    data_seq_sumLinAll_1[is.na(data_seq_sumLinAll_1)] <- 0
    
    all_abun <- data_seq_sumLinAll_1 %>%
      complete(collection_date = seq.Date(as.Date("2021-09-24"), as.Date(max_coll_date_gen), by = "day")) %>%
      fill(everything(), .direction = "down") %>%
      pivot_longer(cols = -collection_date, values_to = "percentageAll", names_to = "summarized_lineage")
    
    # Filter by input dates
    start_date <- input$date_input[1]
    end_date <- input$date_input[2]
    
    all_abun <- all_abun %>%
      filter(collection_date >= start_date & collection_date <= end_date)

    marker_style <- list(line = list(width = 0,
                                     color = 'rgb(0, 0, 0)'));
    
     plot_ly(all_abun,
                  x = ~collection_date,
                  y = ~percentageAll,
                  type = 'bar',
                  color = ~summarized_lineage,
                  colors = lineageColors,
                  marker = marker_style,
                  text = ~paste0("<b>Wastewater sequence data</b>", "<br>",
                                 `collection_date`, "<br>",
                                 "Lineage: ", `summarized_lineage`, "<br>",
                                 "Percent of sample: ", round_half_up(percentageAll, 1), "%"),
                  textposition = "none",
                  hovertemplate = "%{text}<extra></extra>") %>%
      layout(xaxis = list(hoverformat = c(~percentageAll, ~collection_date))) %>%
      layout(yaxis = list(title = list(text = 'Variant abundance (%)',
                                       font = list(size = 12)),
                          range = c(0, 100)),
             barmode = "stack",
             legend=list(traceorder = 'normal'),
             xaxis = list(title = 'Collection date'))

  })


} # /server



# Run the application -----
shinyApp(ui = ui, server = server)
