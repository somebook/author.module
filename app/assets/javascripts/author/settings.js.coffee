jQuery ->
  $(".terminal-params").on 'click', (e) ->
    $(this).parent().toggleClass("active")
    $(this).parent().parent().parent().parent().find('.add-terminal').slideToggle('fast')
    return false
    
  $(".terminal-connect").on 'click', (e) ->
    $("li[data-terminal=" + $(this).data("terminal-id") + "]").find('form').submit()
    $("li[data-terminal=" + $(this).data("terminal-id") + "]").addClass("removed")
    return false
    
  $("a.accordion-toggle").on 'click', (e) ->
    loadTerminals($(this).data("terminal"))
    $($(this).attr("href")).toggle()
    return false
    
  loadTerminals = (account) ->
    if $("ul.terminals[data-terminal=" + account + "] > li").size() == 0
      $.get('/author/settings/accounts/' + account + '/terms', (data) ->
        $("ul.terminals[data-terminal=" + account + "]").html(data)
      )
      
  $("form").on 'submit', (e) ->
    $('input[type=submit]', this).button('loading')