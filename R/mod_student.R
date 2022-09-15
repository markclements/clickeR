#' student UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_student_ui <- function(id) {
  ns <- NS(id) # nolint
  htmltools::tagList(
    tags$head(
        HTML(
          "
          <script>
          var socket_timeout_interval
          var n = 0
           $(document).on('shiny:connected', function(event) {
           socket_timeout_interval = setInterval(function(){
           Shiny.onInputChange('student-count', n++)
           $('#student-keepAlive').hide();
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          
          </script>
          "
        )
        ),
   # htmltools::tags$script(src = "www/student.js"),
    htmltools::h3("Welcome! "),
    textOutput(ns("keepAlive")),
    shiny::uiOutput(ns("question_ui"))
  )
}

#' student Server Functions
#'
#' @noRd
mod_student_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    session$allowReconnect("force")

    output$keepAlive <- renderText({
      req(input$count)
      paste("keep alive ", input$count)
    })

    output$question_ui <- shiny::renderUI({
        if (is.null(student_ui())) {
                div(
                    id = "blank",
                    h3("The next question will start soon")
                )
        }
        else if (student_ui()[1] == "multiple choice") {
                div(
                    id = "mc",
                    radioButtons(
                        inputId = ns("question_mc"),
                        label = "Choose the best answer",
                        choices = LETTERS[1:student_ui()[[2]]]
                    ),
                      actionButton(
                        inputId = ns("submit_mc"),
                        label = "submit"
                    ) |> tagAppendAttributes(onclick = "displayRadioValue()"),
                    div(
                      id = "result"
                    )
                )
        }
        else if (student_ui()[1] == "text") {
                    div(
                        id = "question_text",
                        textAreaInput(
                            inputId = ns("question_text"),
                            label = "enter words"
                        ),
                        actionButton(
                          inputId = ns("submit_text"),
                          label = "submit"
                        )
                    )
        }
        else if (student_ui[1] == "answer") {
           #plotOutput("hist")
        }
    })

    observeEvent(input$submit_mc, {
        df <- answers_df()

        if (is.null(df)) {
            df <- tibble::tibble(
                                id = session$token,
                                ques_id = ques_id(),
                                ans = input$question_mc,
                                time = Sys.time())
        }
        else {
          df <- df |>
          tibble::add_row(id = session$token,
                          ques_id = ques_id(),
                          ans = input$question_mc,
                          time = Sys.time()) #|>
          #dplyr::filter(id %in% global_user_list())
        }
        answers_df(df)
    })

    observeEvent(input$submit_text, {
        df <- answers_df()

        if (is.null(df)) {
            df <- tibble::tibble(
                                id = session$token,
                                ques_id = ques_id(),
                                ans = input$question_text,
                                time = Sys.time())
        }
        df <- df |>
        tibble::add_row(id = session$token,
                        ques_id = ques_id(),
                        ans = input$question_text,
                        time = Sys.time()) #|>
        #dplyr::filter(id %in% global_user_list())
        answers_df(df)
    })
  })
}


#' Page Functions
#'
#' @noRd
#' @importFrom brochure page
student <- function(id = "student", href = "/student") {
  page(
    href = href,
    ui = mod_student_ui(id = id),
    server = function(input, output, session) {
      mod_student_server(id = id)
    }
  )
}

# Add this to the brochureApp call in R/studentrun_app.R
# student() # nolint
