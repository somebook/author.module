jQuery ->
  $(document).on 'click', "#patterns.modal .pattern", (e) ->
    $("#patterns.modal .form-create").hide()
    $("#patterns.modal .form-update").show()
    $("#patterns.modal .form-update").attr("action", "/author/publication_patterns/" + $(this).parent().data("pattern-id"))
    $("#patterns.modal .form-update input#publication_pattern_terminals").attr("value", $(this).data("terminals"))
    $("#patterns.modal input.name").attr("value", $(this).find("strong").text())
    terminals = $(this).data("terminals")
    $("#patterns.modal input[type=checkbox]").attr("checked", null)
    $("#patterns.modal input[type=checkbox]").each(
      ->
        if terminals.indexOf($(this).data("terminal-id")) > -1
          $(this).click()
    )
    return false
    
  $(document).on 'click', ".add-pattern", (e) ->
    $("#patterns.modal .form-create").show()
    $("#patterns.modal .form-update").hide()
    $("#patterns.modal .form-update input#publication_pattern_terminals").attr("value", "")
    $("#patterns.modal input.name").attr("value", "")
    $("#patterns.modal input[type=checkbox]").attr("checked", null)
    return false
    
  $(document).on 'keyup', "#patterns.modal input.name.fake", (e) ->
    if $("#patterns.modal .form-create").css("display") == 'none'
      $("#patterns.modal .form-update input.name.real").attr("value", $(this).attr("value"))
    else
      $("#patterns.modal .form-create input.name.real").attr("value", $(this).attr("value"))
      
  $(document).on 'change', "#patterns.modal input[type=checkbox]", (e) ->
    terminals = []
    $("#patterns.modal input[type=checkbox]").each(
      ->
        if $(this).attr("checked") == "checked"
          terminals.push($(this).data("terminal-id"))
    )
    if $("#patterns.modal .form-create").css("display") == 'none'
      $("#patterns.modal .form-update input.terminals").attr("value", terminals)
    else
      $("#patterns.modal .form-create input.terminals").attr("value", terminals)