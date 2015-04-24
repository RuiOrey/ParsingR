source("..procura/procura.R")

shinyServer(
	function(input, output) {
		output$plot <- renderPlot({
			procura(input$keywords, input$max)
		})
	}
)
