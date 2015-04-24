source("..pre/search.R")

shinyServer(
	function(input, output) {
		output$plot <- renderPlot({
			search(input$keywords, input$max)
		})
	}
)
