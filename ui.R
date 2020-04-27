ui<-navbarPage(title="clickeR",
               tabPanel(title="student",
                        textInput(inputId="student_id",label = "ID"),
                        uiOutput("question_type")),
               tabPanel(title="instructor",
                        selectInput(inputId="question",
                                    label="select question type",
                                    choices = c("MC","Text"),
                                    selected = "MC"),
                        actionButton(inputId="submit",label = "submit"),
                        verbatimTextOutput("var"),
                        verbatimTextOutput("ans"))
               )
