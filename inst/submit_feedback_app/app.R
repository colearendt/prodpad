library(shiny)
library(shinycssloaders)
library(prodpad)

pcli <- prodpad()

ui <- fluidPage(

    titlePanel("Submit New Feedback"),


    fluidRow(
      column(12, div(actionButton("clear", "Clear")))
    ),
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
      column(3), column(3, actionButton("submit", "Submit")),
      column(3, actionButton("interrupt", "Interrupt")),
      column(3, actionButton("refresh_feedbacks", "Update Feedbacks"))
    ),
    fluidRow(
      column(
        12,
        tabsetPanel(
          tabPanel(
            "My Recent Feedbacks",
            reactable::reactableOutput("feedback_my_recent")
            ),
          tabPanel("Customer Recent Feedbacks")
        )
        )
    )
)

server <- function(input, output, session) {
  all_contacts <- get_contacts(pcli)
  output$select_contact <- renderUI({
     selectizeInput(
          "contact",
          "Contact",
          choices = c("Select a Contact" = "", rlang::set_names(all_contacts$id, all_contacts$name)),
          options = list(create = TRUE) # TODO: handle creation better
          )
  })

  all_products <- get_products(pcli)
  output$select_product <- renderUI({
      selectizeInput(
          "products",
          "Products",
          choices = rlang::set_names(all_products$product_id, all_products$name),
          multiple = TRUE
          )
  })

  all_personas <- get_personas(pcli)
  output$select_personas <- renderUI({
      selectizeInput(
          "personas",
          "Personas",
          choices = rlang::set_names(all_personas$persona_id, all_personas$name),
          multiple = TRUE
          )
  })

  all_tags <- get_tags(pcli)
  output$select_tags <- renderUI({
      selectizeInput(
          "tags",
          "Tags",
          choices = rlang::set_names(all_tags$tag_id, all_tags$tag),
          multiple = TRUE
          )
  })

  observeEvent(input$submit, {
    showNotification("Submitting feedback...", type = "message")

    res <- tryCatch({
     feedback(
        pcli,
        contact = input$contact,
        tags = input$tags,
        personas = input$personas,
        products = input$products,
        source = input$source,
        links = input$links,
        feedback = input$description
        )
    }, error = function(e) {
      showNotification(
        glue::glue("ERROR sending feedback: {e}"),
        type = "error"
        )
      return(NULL)
    })

    showNotification("Feedback sent!", type = "message")
    if (!is.null(res)) {
      furl <- feedback_url(res$feedbacks$id)
      showNotification(
        htmltools::a(href = furl, glue::glue("See the feedback here: {furl}")),
        duration = NULL
      )
    }
  })

  # View feedbacks

  feedbacks <- reactiveVal(data.frame())

  observeEvent(input$refresh_feedbacks, {
    showNotification("Feedbacks: fetching... please wait")
    feedbacks(get_feedback(pcli))
    showNotification("Feedbacks: Done!")
  })

  observeEvent(input$interrupt, {
    browser()
  })

  output$feedback_my_recent <- reactable::renderReactable({
    req(ncol(feedbacks()) > 0)
    feedbacks() %>%
      filter(added_by_id == pp_me(pcli)$user$id) %>%
      select(created_at, feedback) %>%
      arrange(desc(created_at)) %>%
      head(20) %>%
      reactable::reactable()
  })

  observeEvent(input$clear, {
    showNotification("Clearing inputs", type = "message")
    updateSelectizeInput(session, "contact", selected = "")
    updateSelectizeInput(session, "tags", selected = "")
    updateSelectizeInput(session, "personas", selected = "")
    updateSelectizeInput(session, "products", selected = "")
    updateSelectizeInput(session, "source", selected = "")
    updateSelectizeInput(session, "links", selected = "")
    updateTextAreaInput(session, "description", value = "")
  })
}

shinyApp(ui = ui, server = server)
