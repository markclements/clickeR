##  a single app with mutliple tabs. A student tab and instructor tab. Password protect or 
##  hide instructor tab from students (somehow). A rective shared among all sessions that  
##  determines how to renderUI student interface. This reactive can be changed upated by
##  instructor. The ui determining reactive could be stored persistantly somewhere on 
##  the server or google drive. 
##

global_var<-reactiveValues(qt=NULL)

server<-function(session,input,output){

  observeEvent(input$submit,{
    global_var$qt<<-input$question
  })
  
  output$question_type<-renderUI({
    
    if (is.null(global_var$qt)) p("wait")
    else if (global_var$qt=="MC") div(radioButtons(inputId = "mult_choice", 
                                                   label="pick an answer",
                                                   choices = c("a","b"),
                                                   selected = "a"),
                                      actionButton("submit","sub_ans")
                                      )
    else if (global_var$qt=="Text") div(textInput(inputId = "text", 
                                                  label = "type a short answer"),
                                        actionButton("submit","sub_ans")
                                        )
   
    })

  output$var<-renderText({global_var$qt})
  output$ans<-renderText({if (global_var$qt=="MC") input$mult_choice
                          else if (global_var$qt=="Text") input$text
                          else "nothing yet"})
                           
}
