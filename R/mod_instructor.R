#' instructor UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_instructor_ui <- function(id) {
  ns <- NS(id)
  tagList(
    col_6(
      h1("Instructor UI"),
      shiny::selectInput(
        inputId = ns("select_global"),
        label = "select",
        choices = c("multiple choice", "text")
      ),
      shiny::actionButton(
        inputId = ns("start"),
        label = "Start"
      ),
      shiny::actionButton(
        inputId = ns("stop"),
        label = "Stop"
      )
    ),
    col_6(
      verbatimTextOutput(
        ns("responses")
      )
    )  
  )
}

#' instructor Server Functions
#'
#' @noRd
mod_instructor_server <- function(id) {
  

  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$start, {
      student_ui(input$select_global)
   })

   observeEvent(input$stop, {
      student_ui(NULL)
   })

   onStop(
    function() {
      isolate(student_ui(NULL)) ##resets UI if instructor is not connected
    }
  )

  
  output$responses <- renderPrint({
    answers_df() |> dim() 
})
    
  })
}

#' Page Functions
#'
#' @noRd
#' @importFrom brochure page
instructor <- function(id = "instructor", href = "/instructor") {
  page(
    href = href,
    ui = mod_instructor_ui(id = id),
    server = function(input, output, session) {
      mod_instructor_server(id = id)
    }
  )
}

# Add this to the brochureApp call in R/instructorrun_app.R
# instructor()
