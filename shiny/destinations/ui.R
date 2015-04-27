library(shiny)

shinyUI(
  # Application title
  fluidPage(title="Destinations",

    fluidRow(
      column(4,
       uiOutput("choose_dataset"),
      #hr(),
      conditionalPanel(condition="$('html').hasClass('shiny-busy')",
       tags$div(style="float:right; padding-right:10px; padding-top:10px; color:yellow; background-color:red; font-family:arial; font-size:20px","WAIT")),
      h2(textOutput("name")),
      h3(textOutput("type")),
      h5(textOutput("quality")),
      h4("Alias"),
      h5(textOutput("alias")),
      h4("Path"),
      h5(textOutput("father"))
      ),
      column(4,
        h4("Location"),
        h5(textOutput("cordinates")),
        plotOutput("map")
        ),
      column(4,
        h4("Search terms"),
        plotOutput("plot"),
        h6("takes some time to load...")
        )
      )


#mainPanel(
    # Show Word Cloud
#    )
  )
  )

a