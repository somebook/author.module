jQuery ->
  $(document).on 'click', ".terminal-params", (e) ->
    $(this).parent().toggleClass("active")
    $(this).parent().parent().parent().parent().find('.add-terminal').slideToggle('fast')
    return false
    
  $(document).on 'click', ".terminal-connect", (e) ->
    $("li[data-terminal=" + $(this).data("terminal-id") + "]").find('form').submit()
    $("li[data-terminal=" + $(this).data("terminal-id") + "]").addClass("removed")
    return false
    
  $(document).on 'click', ".terminal-connect-fail", (e) ->
    alert "With free tariff you cannot connect groups, pages and events. Please, upgrade to pro or premium tariff."
    return false
    
  $(document).on 'click', "a.accordion-toggle", (e) ->
    loadTerminals($(this).data("terminal"))
    $($(this).attr("href")).toggle()
    return false
    
  loadTerminals = (account) ->
    if $("ul.terminals[data-terminal=" + account + "] > li").size() == 0
      $.get('/author/settings/accounts/' + account + '/terms', (data) ->
        $("ul.terminals[data-terminal=" + account + "]").html(data)
      )
      
  $(document).on 'submit', "form", (e) ->
    $('input[type=submit]', this).button('loading')