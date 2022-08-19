#' global_param 
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

# global reacitve values
# student_ui holds the variable to determine the student UI, a list with 2 elements
student_ui <- shiny::reactiveVal()

# answers_df holds the answers submitted by students
answers_df <- shiny::reactiveVal()

# unique question id
ques_id <- shiny::reactiveVal()
