### Server
server <- function(input, output) {
  
  output$table <- DT::renderDataTable({
    DT::datatable(
      create_view_history(),
      options = list(
        processing = FALSE
      )
    )
  })
  
}