jQuery ->
  $(".service a.password_auth").live 'click', (e) ->
    $(this).siblings('.password_auth_form').toggle(50)
    false