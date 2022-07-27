library(shiny)
library(brochure)

# We'll start by defining a home page
home <- function(
  httr_code
){
  page(
    href = "/",
    # Simple UI, no server side
    ui = tagList(
      tags$head(
        tags$script(
         "var source = new EventSource('/post');
         source.addEventListener('open', function(e) {
          console.log('Connection Opened')
         document.getElementById('content').innerHTML += 'Connections to the server established..<br/>';
         }, false);
         source.onmessage = function(e) {
         document.getElementById('content').innerHTML += e.data + '<br/>';
         };
         document.getElementById('stopButton').onclick=function() {
         document.getElementById('content').innerHTML += 'Listening to server events stopped..<br/>';
         source.close();
         }"
        )
      ),
      tags$h1("Hello world!"),
      tags$p("Open a new R console and run:"),
      tags$pre(
        httr_code
      ),
      tags$div(
        id = "content"
      )
    )
  )
}

postpage <- function(){
  page(
    href = "/post",
    req_handlers = list(
      function(req){
        if( req$REQUEST_METHOD == "GET" ){
          return(
            httpResponse(
              status = 200,
              content_type = "text/event-stream",
              content = "data: Created \n\n",
              headers = list(
                "Cache-Control" = "no-store"
              )
            )
          )
        }
        return(req)
      }
    ),
    ui = tagList(
      tags$p("Hello from /post!")
    )
  )
}
brochureApp(
  home(
    httr_code = "httr::POST('http://127.0.0.1:2811/post', body = 'plop')"
  ),
  postpage()
)
# For the sake of reproducibility:
options(shiny.port = 2811)