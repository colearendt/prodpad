library(shiny)
library(shinycssloaders)
library(prodpad)

pcli <- prodpad()

ui <- fluidPage(

    titlePanel("Submit New Feedback"),


    fluidRow(
        column(6, div(withSpinner(uiOutput("select_contact")))),
        column(6, div(withSpinner(uiOutput("select_product"))))
    ),
    fluidRow(
      column(12,textAreaInput("description", "Feedback", resize = "both", width = "100%", placeholder = "Describe the problem being faced"))
    ),
    fluidRow(
      column(6, withSpinner(uiOutput("select_personas"))),
      column(6, withSpinner(uiOutput("select_tags")))
    ),
    fluidRow(
      column(6,selectizeInput("links", choices = list(), options = list(create=TRUE), "External Links", multiple = TRUE)),
      column(6,selectizeInput("source", "Source", choices = c("None" = "",prodpad::feedback_sources), selected = ""))
    ),
    fluidRow(
      column(3), column(3, actionButton("submit", "Submit"))
    )
)

server <- function(input, output) {
  all_contacts <- get_contacts(pcli)
  output$select_contact <- renderUI({
     selectizeInput(
          "contact",
          "Contact",
          choices = c("Select a Contact" = "", rlang::set_names(all_contacts$id, all_contacts$name)),
          options = list(create = TRUE)
          )
  })

  all_products <- get_products(pcli)
  output$select_product <- renderUI({
      selectizeInput(
          "products",
          "Products",
          choices = rlang::set_names(all_products$id, all_products$name),
          multiple = TRUE
          )
  })

  all_personas <- get_personas(pcli)
  output$select_personas <- renderUI({
      selectizeInput(
          "personas",
          "Personas",
          choices = rlang::set_names(all_personas$id, all_personas$name),
          multiple = TRUE
          )
  })

  all_tags <- get_tags(pcli)
  output$select_tags <- renderUI({
      selectizeInput(
          "tags",
          "Tags",
          choices = rlang::set_names(all_tags$id, all_tags$tag),
          multiple = TRUE
          )
  })
}

shinyApp(ui = ui, server = server)
