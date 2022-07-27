library(shiny)

global_ui_var <- reactiveVal()
global_user_list <- reactiveVal()
global_sub <- reactiveVal()

ui <- shiny::fluidPage(
    h2("Instructor View"),
    shiny::selectInput( 
        inputId = "show_ui",
        label = "choose ui",
        choices = c("multiple choice", "text", "answer")
    ),
    actionButton(
        inputId = "update_ui",
        label = "update ui"
    ),
   # plotOutput("ans"),
    verbatimTextOutput("ans"),
    htmltools::h2("Student View"),
    htmltools::hr(),
    shiny::uiOutput("global_ui")
)

server <- function(input, output, session) {

    isolate({
        global_user_list(c(global_user_list(), session$token))
    })

    onStop(
        function() {
            isolate({
               list <- global_user_list()
               list <- list[list != session$token]
               global_user_list(list)
            })
        }
    )

    observeEvent(input$update_ui, {
        global_ui_var(input$show_ui)
    })

    output$global_ui <- shiny::renderUI({
        if (is.null(global_ui_var())) {
                div(
                    id = "blank",
                    h3("wait")
                )
        }
        else if (global_ui_var() == "multiple choice") {
                div(
                    id = "mc",
                    radioButtons(
                        inputId = "question",
                        label = "select one",
                        choices = c("a", "b", "c", "d")
                    ),
                        actionButton(
                        inputId = "submit",
                        label = "submit"
                    )
                )
        }
        else if (global_ui_var() == "text") {
                    div(
                        id = "question",
                        textAreaInput(
                            inputId = "text",
                            label = "enter words"
                        ),
                        actionButton(
                        inputId = "submit",
                        label = "submit"
                        )
                    )       
        }
        else if (global_ui_var() == "answer") {
           plotOutput("hist")
        }
    })

    observeEvent(input$submit, {
        ans <- global_sub()

        if (is.null()) {
            ans <- tibble::tibble(
                                id = session$token,
                                ans = input$question,
                                time = Sys.time())
        }
        ans <- ans |>
        tibble::add_row(id = session$token,
                        ans = input$mc,
                        time = Sys.time()) |>
        dplyr::filter(id %in% global_user_list())
        global_sub(ans)
    })

    output$ans <- renderPrint({
        if (is.null(global_sub())) {
                return()
        } else {
        global_sub() |>
            dplyr::group_by(id) |>
            dplyr::slice(dplyr::n()) |>
            dplyr::group_by(ans) |>
            dplyr::count() -> df
        }
        df
    })

    output$hist <- renderPlot({
        global_sub() |>
            dplyr::group_by(id) |>
            dplyr::slice(dplyr::n()) |>
            dplyr::group_by(ans) |>
            dplyr::count() -> df

        df |>
            ggplot2::ggplot() +
            ggplot2::geom_col(ggplot2::aes(x = ans, y = n))
    })
}

shinyApp(ui, server)
