library(ambiorix)
library(htmltools)
#library(scilis)

PORT <- 3000L

#googlesheets4::gs4_auth(path = "practical-net-355517-e741eb612f15.json")

app <- Ambiorix$new(port = PORT)

# app$use(\(req, res) {
#     print(Sys.time())
# })

#app$use(scilis("secret"))

# app$post("/", \(req, res) {
#     body <- parse_json(req)
#     print(body)
    #googlesheets4::sheet_append(ss= "1NMB6XP7GBsOmMDT2DcQUOV8MOobCSYZJb0pAgUQl5uU", tibble::tibble(user_id = body))
# })

# app$get("/", function(req, res) {
#     res$render("index.html")
# })

# app$get("talk", \(req, res) {
#     time <- Sys.time()
#     string <- paste0("data:", time, "\n\n")
#     res$header("Cache-Control", "no-store")
#     res$header("Connection", "keep-alive")
#     res$header("Content-Type", "text/event-stream")
#     res$send(string)
# })

app$get("/", \(req, res){

  # form
  # sends to /submit
  form <- tagList(
    tags$form(
      action = "/submit", 
      enctype = "multipart/form-data", 
      method = "POST",
      tags$p(
        tags$label(`for` = "first_name", "First Name"),
        tags$input(type = "text", name = "first_name")
      ),
      tags$input(type = "submit")
    )
  )
  print(form)
  res$send(form)
})

app$post("/submit", \(req, res){
  body <- parse_multipart(req)
  res$send(h1("Your name is", body$first_name))
})


app$start()
