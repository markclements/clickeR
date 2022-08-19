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
      shiny::numericInput(
        inputId = ns("num_choices"),
        label = "number of mc options",
        value = 4,
        min = 1,
        step = 1,
      ),
      shiny::actionButton(
        inputId = ns("start"),
        label = "Start"
      ),
      shiny::actionButton(
        inputId = ns("stop"),
        label = "Stop"
      ), 
      span(id = "min", "00"),
      span(":"),
      span(id = "sec", "00")
    ),
    col_6(
      fluidRow(
        shiny::verbatimTextOutput(
            ns("responses"),
        )
      ),
      fluidRow(
        shiny::selectInput(
          inputId = ns("ques_id"),
          label = "select a question to dispaly",
          choices = c()
        ), 
        shiny::actionButton(
          inputId = ns("plot"),
          label = "Show Results"
        )
      ),
      fluidRow(
        shiny::plotOutput(ns("results"))
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
        student_ui(list(input$select_global, input$num_choices))
        ques_id(paste0(sample(LETTERS, 8, replace = TRUE), collapse = ""))
   })

   observeEvent(input$stop, {
      student_ui(NULL)
   })

   onStop(
    function() {
      isolate(student_ui(NULL)) ## resets stuent UI (and reactiveVal) if instructor is not connected or gets disconnected 
      }
    )

    output$responses <- renderPrint({
      shiny::req(answers_df())
      answers_df() |>
        dplyr::filter(
          ques_id == ques_id()
        ) |>
        dplyr::group_by(
          id
        ) |>
        dplyr::slice(dplyr::n()) |>
        dplyr::ungroup() |>
        dplyr::count() |>
        dplyr::pull(n) -> number_resp

        cat(number_resp, "students have submitted answers to question id", ques_id())
    })

    observeEvent(input$stop, {

      req(answers_df())

      answers_df() |>
        # dplyr::arrange(
        #   dplyr::desc(time)
        # ) |>
        dplyr::group_by(ques_id) |>
        dplyr::slice_min(time, with_ties = FALSE) |>
        dplyr::ungroup() |>
        dplyr::arrange(
          dplyr::desc(time)
         ) |>
        dplyr::mutate(id_time = paste0(ques_id, " - ", time)) |>
        dplyr::ungroup() |>
        (\(.) split(.$ques_id, .$id_time))() -> choices

      shiny::updateSelectInput(
        session = session,
        inputId = "ques_id",
        choices = choices,
        selected = choices[length(choices)]
      )
    })

    observeEvent(input$plot, {
      req(answers_df())

      
      answers_df() |>
        dplyr::filter(
          ques_id == input$ques_id
        ) |>
        dplyr::group_by(
          id
        ) |>
        dplyr::slice(dplyr::n()) |>
        dplyr::ungroup() -> x

        output$results <- shiny::renderPlot({
        ggplot2::ggplot(x) +
        ggplot2::aes(x = ans) +
        ggplot2::geom_histogram(stat = "count")
      })
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
