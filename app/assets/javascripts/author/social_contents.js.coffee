jQuery ->
  $("table.social a.show").live 'click', (e) ->
    if $(this).text() == "Show" or $(this).text() == "Просмотр"
      $(this).parent().parent().find('.terminal-form').slideDown('fast')
      $(this).text('Hide') if $(this).text() == "Show"
      $(this).text('Скрыть') if $(this).text() == "Просмотр"
      $(this).siblings('.edit').css('display', 'block')
    else
      $(this).parent().parent().find('.terminal-form').slideUp('fast')
      $(this).text('Show') if $(this).text() == "Hide"
      $(this).text('Просмотр') if $(this).text() == "Скрыть"
      $(this).siblings('.edit').css('display', 'none')
    false

  $("table.social input:radio").live 'click', (e) ->
    $(".#{$(this).data('social-content-id')}").attr("disabled", "disabled")
    $(this).next().next().removeAttr("disabled")

  $("table.social .copy").live 'click', (e) ->
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
          $("table.social .generated textarea.#{$(this).data('content-id')}").each(
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

  sanitize = (str) ->
    str.replace(/[\s\n\r]+/g, ' ')
      .replace(/<\/p><p>/g, '</p>[br]<p>')
      # .replace(/<iframe.*src=\"([^"]*).*iframe>/g, ' $1 ')
      # .replace(/<(\/*i|\/*p|\/*b)>/g, '[$1]')

  $("table.social a.edit").live 'click', (e) ->
    if $(this).text() == "Edit" or $(this).text() == "Изменить"
      $(this).parent().parent().find('.edited').slideDown('fast')
      $(this).text('Cancel') if $(this).text() == "Edit"
      $(this).text('Отменить') if $(this).text() == "Изменить"
    else
      $(this).parent().parent().find('.edited').slideUp('fast')
      $(this).text('Edit') if $(this).text() == "Cancel"
      $(this).text('Изменить') if $(this).text() == "Отменить"