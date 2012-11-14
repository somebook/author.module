#= require author/wysiwyg
#= require author/social_contents

jQuery ->
  $("ul.nav-pills > li").live 'click', (e) ->
    $(this).siblings().removeClass("active")
    $(this).addClass("active")
    $(".content_form").hide()
    $(".content_form_" + $(this).attr('data-language-id')).show()
    false

  $("#buy_tickets").live 'change', (e) ->
    if $(this).attr("checked") == "checked"
      $(this).parent().parent().find("input[type='text']").removeAttr("disabled")
    else
      $(this).parent().parent().find("input[type='text']").attr("disabled", "disabled")