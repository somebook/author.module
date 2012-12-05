jQuery ->
  $(".terminal-params").live 'click', (e) ->
    $(this).parent().toggleClass("active")
    $(this).parent().parent().parent().parent().find('.add-terminal').slideToggle()
    return false
    
  $(".terminal-connect").live 'click', (e) ->
    $("li[data-terminal=" + $(this).data("terminal-id") + "]").find('form').submit()
    $("li[data-terminal=" + $(this).data("terminal-id") + "]").addClass("removed")
    return false
    
  $("a.accordion-toggle").live 'click', (e) ->
    loadTerminals($(this).data("terminal"))
    $($(this).attr("href")).slideToggle()
    return false
    
  loadTerminals = (account) ->
    if $("ul.terminals[data-terminal=" + account + "] > li").size() == 0
      $.get('/author/settings/accounts/' + account + '/terms', (data) ->
        $("ul.terminals[data-terminal=" + account + "]").html(data)
      )
      
  $("form").submit(
    ->
      $('input[type=submit]', this).button('loading')
  )