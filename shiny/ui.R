library(shiny)

shinyUI(
	fluidPage(
		titlePanel("Moontrip"),

		sidebarLayout(
			sidebarPanel(
				textInput("keywords", "Keywords:", "surf"),
				sliderInput("max", "Maximum cities:", min=1,  max=500, value=100)
			),
			mainPanel(
				plotOutput("plot")
			)
		)
	)
)
