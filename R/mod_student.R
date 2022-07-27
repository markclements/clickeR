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
  ns <- NS(id)
  tagList(
    h1("Student UI"),
    uiOutput(ns("question_ui"))
  )
}

#' student Server Functions
#'
#' @noRd
mod_student_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$question_ui <- shiny::renderUI({
        if (is.null(student_ui())) {
                div(
                    id = "blank",
                    h3("wait")
                )
        }
        else if (student_ui() == "multiple choice") {
                div(
                    id = "mc",
                    radioButtons(
                        inputId = ns("question_mc"),
                        label = "select one",
                        choices = c("a", "b", "c", "d")
                    ),
                      actionButton(
                        inputId = ns("submit_mc"),
                        label = "submit"
                    )
                )
        }
        else if (student_ui() == "text") {
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
        else if (student_ui == "answer") {
           #plotOutput("hist")
        }
    })

    observeEvent(input$submit_mc, {
        df <- answers_df()

        if (is.null(df)) {
            df <- tibble::tibble(
                                id = session$token,
                                ans = input$question_mc,
                                time = Sys.time())
        }
        else {
          df <- df |>
          tibble::add_row(id = session$token,
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
                                ans = input$question_text,
                                time = Sys.time())
        }
        df <- df |>
        tibble::add_row(id = session$token,
                        ans = input$question_text,
                        time = Sys.time()) #|>
        #dplyr::filter(id %in% global_user_list())
        answers_df(df)
        print(answers_df())
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
# student()
