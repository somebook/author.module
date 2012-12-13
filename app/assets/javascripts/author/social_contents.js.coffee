jQuery ->
  $("#social_connections.connections a.edit").live 'click', (e) ->
    if $(this).text() == "Edit" or $(this).text() == "Изменить"
      $(this).parent().parent().parent().find('.terminal-form').slideDown('fast')
      $(this).text('Hide') if $(this).text() == "Edit"
      $(this).text('Скрыть') if $(this).text() == "Изменить"
      $(this).siblings('.edit').css('display', 'block')
    else
      $(this).parent().parent().parent().find('.terminal-form').slideUp('fast')
      $(this).text('Edit') if $(this).text() == "Hide"
      $(this).text('Изменить') if $(this).text() == "Скрыть"
      $(this).siblings('.edit').css('display', 'none')
    return false

  $("#social_connections.connections input:radio").live 'click', (e) ->
    $(".#{$(this).data('social-content-id')}").attr("disabled", "disabled")
    $(this).next().next().removeAttr("disabled")

  $("#social_connections.connections .copy").live 'click', (e) ->
    $(this).next().next().next().val($(this).parent().prev().find('textarea').val())
    false

  setInterval(
    ->
      $("textarea.w").each(
        ->
          tmp = document.createElement("div")
          tmp.innerHTML = sanitize($(this).val())
          body = (tmp.textContent || tmp.innerText).replace(/\[br\]/g, '\r')#.replace(/\[(\/*i|\/*p|\/*b)\]/g, '<$1>')
          title = $("input.content-title.#{$(this).data('content-id')}").val()
          $("#social_connections.connections .generated textarea.#{$(this).data('content-id')}").each(
            ->
              counter = $(this).parent().parent().parent().find(".counter")
              if $(this).data('provider') == "twitter"
                if $(this).val().length > 120
                  $(counter).addClass("label-important")
                else
                  $(counter).removeClass("label-important")
                $(counter).text(120 - $(this).val().length)
              $(this).val(body) if $(this).val() != body
          )
      )
    1000
  )
  
  $("#social_connections.connections a.accordion-toggle").live 'click', (e) ->
    $($(this).attr('href')).toggle()
    false

  sanitize = (str) ->
    str#.replace(/[\s]+/g, ' ')
      .replace(/<\/p><p>/g, '</p>[br]<p>')
      # .replace(/<iframe.*src=\"([^"]*).*iframe>/g, ' $1 ')
      # .replace(/<(\/*i|\/*p|\/*b)>/g, '[$1]')

  # $(".connections a.edit").live 'click', (e) ->
  #   if $(this).text() == "Edit" or $(this).text() == "Изменить"
  #     $(this).parent().parent().parent().find('.edited').slideDown('fast')
  #     $(this).text('Cancel') if $(this).text() == "Edit"
  #     $(this).text('Отменить') if $(this).text() == "Изменить"
  #   else
  #     $(this).parent().parent().parent().find('.edited').slideUp('fast')
  #     $(this).text('Edit') if $(this).text() == "Cancel"
  #     $(this).text('Изменить') if $(this).text() == "Отменить"
  #   return false
  
  $("#social_connections.connections input[type=checkbox]").live 'change', (e) ->
    contents = $(this).parent().contents()
    if $(this).attr('checked') == "checked" && $(this).parent().hasClass("label") && $(this).parent().parent().parent().parent().find('.terminal-form .generated input[type=radio]').attr("checked") == "checked"
      $(this).parent().removeClass("edited").addClass("auto")
      contents[contents.length - 1].nodeValue = "Auto"
    else if $(this).attr('checked') == "checked" && $(this).parent().hasClass("label") && $(this).parent().parent().parent().parent().find('.terminal-form .edited input[type=radio]').attr("checked") == "checked"
      $(this).parent().removeClass("auto").addClass("edited")
      contents[contents.length - 1].nodeValue = "Edited"
    else
      $(this).parent().removeClass("auto").removeClass("edited")
      contents[contents.length - 1].nodeValue = "None"
      
    new_terminals = []
    $("#social_connections.connections input[type=checkbox]").each(
      ->
        if $(this).attr("checked") == "checked"
          new_terminals
          new_terminals.push($(this).data("terminal-id"))
          new_terminals
    )
    if $(".post-settings .pattern.active").data("terminals")
      terminals = $(".post-settings .pattern.active").data("terminals")
    else
      terminals = []

    if terminals.sort().join() == new_terminals.sort().join()
      $(".post-settings.create").hide()
    else
      $(".post-settings.create").show()
      $("#publication_pattern_terminals").attr("value", new_terminals)

  $("#social_connections.connections input[type=radio]").live 'change', (e) ->
    contents = $(this).parent().parent().parent().find(".clearfix .pull-right .label").contents()
    if $(this).attr('checked') == "checked" && $(this).parent().hasClass("generated") && $(this).parent().parent().parent().find(".clearfix .pull-right input[type=checkbox]").attr("checked") == "checked"
      $(this).parent().parent().parent().find(".clearfix .pull-right .label").removeClass("edited").addClass("auto")
      contents[contents.length - 1].nodeValue = "Auto"
    else if $(this).attr('checked') == "checked" && $(this).parent().hasClass("edited") && $(this).parent().parent().parent().find(".clearfix .pull-right input[type=checkbox]").attr("checked") == "checked"
      $(this).parent().parent().parent().find(".clearfix .pull-right .label").removeClass("auto").addClass("edited")
      contents[contents.length - 1].nodeValue = "Edited"