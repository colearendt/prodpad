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
          tabPanel(
            "All Recent Feedbacks",
            reactable::reactableOutput("feedback_global_recent")
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

  observeEvent(input$submit, {
    browser()
    provided_contact <- input$contact
    if (!input$contact %in% all_contacts) {
      showNotification(glue::glue("Creating contact: {input$contact}"))
      res <- tryCatch({
        pp_create_contact(pcli, input$contact)
      }, error = function(e) {
        showNotification(
          glue::glue("ERROR creating contact: {e}"),
          type = "error"
        )
        print(e)
        return(NULL)
      })
      provided_contact <- res$id
      c_url <- pp_contact_url(provided_contact)
      showNotification(
        htmltools::a(href = furl, glue::glue("See contact here: {c_url}")),
        duration = NULL
      )
    }
    showNotification("Submitting feedback...", type = "message")

    res <- tryCatch({
     feedback(
        pcli,
        contact = provided_contact,
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

  output$feedback_global_recent <- reactable::renderReactable({
    req(ncol(feedbacks()) > 0)
    feedbacks() %>%
      arrange(desc(created_at)) %>%
      select(created_at, added_by_username, feedback) %>%
      head(20) %>%
      reactable::reactable()
  })

  # Presets
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
