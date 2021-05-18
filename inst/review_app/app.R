library(shiny)
library(shinycssloaders)
library(dplyr)
library(prodpad)

pcli <- prodpad()

ui <- fluidPage(

    titlePanel("ProdPad Review"),


    fluidRow(
      column(12, div(actionButton("interrupt", "Interrupt")))
    ),
    tabsetPanel(
      tabPanel(
        "Feedbacks",
        fluidRow(
          column(12, div(actionButton("refresh_feedback", "Refresh Feedbacks")))
        ),
        # TODO: Add filters on these items
        #fluidRow(
        #  column(6, div(withSpinner(uiOutput("select_contact")))),
        #  column(6, div(withSpinner(uiOutput("select_product"))))
        #),
        #fluidRow(
        #  column(6, withSpinner(uiOutput("select_personas"))),
        #  column(6, withSpinner(uiOutput("select_tags")))
        #),
        fluidRow(
          column(
            12,
            withSpinner(reactable::reactableOutput("feedback_global"))
          )
        )
      ),
      tabPanel(
        "Ideas",
        fluidRow(
          column(12, div(actionButton("refresh_ideas", "Refresh Ideas")))
        ),
        fluidRow(
          column(
            12,
            withSpinner(reactable::reactableOutput("ideas"))
          )
        )
      )
    )
)

server <- function(input, output, session) {
  all_contacts <- get_contacts_vector(pcli)
  output$select_contact <- renderUI({
     selectizeInput(
          "contact",
          "Contact",
          choices = c("Select a Contact" = "", all_contacts),
          options = list(create = TRUE) # TODO: handle creation better
          )
  })

  all_products <- get_products_vector(pcli)
  output$select_product <- renderUI({
      selectizeInput(
          "products",
          "Products",
          choices = all_products,
          multiple = TRUE
          )
  })

  all_personas <- get_personas_vector(pcli)
  output$select_personas <- renderUI({
      selectizeInput(
          "personas",
          "Personas",
          choices = all_personas,
          multiple = TRUE
          )
  })

  all_tags <- get_tags_vector(pcli)
  output$select_tags <- renderUI({
      selectizeInput(
          "tags",
          "Tags",
          choices = all_tags,
          multiple = TRUE
          )
  })

  # View feedbacks
  feedbacks <- reactiveVal(get_feedback(pcli))
  ideas <- reactiveVal(get_ideas(pcli))

  observeEvent(input$refresh_feedback, {
    showNotification("Feedbacks: fetching... please wait")
    feedbacks(get_feedback(pcli))
    showNotification("Feedbacks: Done!")
  })

  observeEvent(input$refresh_ideas, {
    showNotification("Ideas: fetching... please wait")
    ideas(get_ideas(pcli))
    showNotification("Ideas: Done!")
  })

  observeEvent(input$interrupt, {
    browser()
  })

  output$feedback_global <- reactable::renderReactable({
    req(ncol(feedbacks()) > 0)
    feedbacks() %>%
      arrange(desc(created_at)) %>%
      mutate(
        fburl = feedback_url(id),
        url = purrr::map_chr(fburl, ~ as.character(htmltools::a(.x, href = .x)))
        ) %>%
      select(created_at, added_by_username, feedback, url) %>%
      reactable::reactable(
        filterable = TRUE, searchable = TRUE,
        columns = list(
          feedback = reactable::colDef(html = TRUE),
          url = reactable::colDef(html = TRUE)
        ))
  })

  output$ideas <- reactable::renderReactable({
    req(ncol(ideas()) > 0)
    ideas() %>%
      arrange(desc(created_at)) %>%
      mutate(
        username = purrr::map_chr(creator, ~ .x$username),
        url = purrr::map_chr(web_url, ~ as.character(htmltools::a(.x, href = .x)))
        ) %>%
      select(created_at, username, title, description, url) %>%
      reactable::reactable(
        filterable = TRUE, searchable = TRUE,
        columns = list(
          title = reactable::colDef(html = TRUE),
          description = reactable::colDef(html = TRUE),
          url = reactable::colDef(html = TRUE)
        )
      )
  })
}

shinyApp(ui = ui, server = server)
