#= require author/wysiwyg
#= require author/social_contents

jQuery ->
  $("ul.langs.nav-pills > li").bind 'click', (e) ->
    $(this).siblings().removeClass("active")
    $(this).addClass("active")
    $(".content_form").hide()
    $(".content_form_" + $(this).attr('data-language-id')).show()
    false

  $(".publish_checkbox").bind 'click', (e) ->
    $(this).prop("checked")
    if $(this).is(':checked') # Disable form
      # $(this).prop("checked", false)
      $(this).parent().removeClass('dont_publish')
      $(".content_form_#{$(this).parent().parent().data('language-id')}").removeClass('dont-publish')
    else # Enable form
      # $(this).prop("checked", true)
      $(this).parent().addClass('dont_publish')
      $(".content_form_#{$(this).parent().parent().data('language-id')}").addClass('dont-publish')
    e.stopPropagation()
    true

  $(".ready_checkbox").on 'change', (e) ->
    if $(this).attr('checked')
      $(this).parent().parent().addClass("ready")
    else
      $(this).parent().parent().removeClass("ready")
    false

  $(".nav-tabs.media > li > a").on 'click', (e) ->
    $(this).parent().siblings().removeClass("active")
    $(this).parent().addClass("active")
    $(".list.media").hide()
    $(".list.#{$(this).data('list')}").show()
    false

  $(".photo, .video").draggable
    helper: "clone"

  $(".gallery .icon-remove").on 'click', (e) ->
    if $(this).parent().parent().find(".thumbnail").size() > 1
      $(this).parent().remove()
    else
      $(this).parent().parent().parent().prepend('<p class="empty">Drop media here.</p>')
      $(this).parent().parent().remove()
    false

  $(".gallery input[type='radio']").bind 'click', (e) ->
    $(this).prop("checked", true)
    e.stopPropagation()
    true

  setDroppable()

  $('.datepicker').datepicker(
    format: "dd.mm.yyyy"
    weekStart: 1
    startDate: new Date()
  )

window.setDroppable = ->
  $(".content_form .wysiwyg").droppable
    accept: ".photo, .video"
    drop: (e) ->
      if $(e.srcElement).hasClass("photo")
        img_src = $(e.srcElement).attr("src")
        html = '<img class="photo" src="'+img_src+'"/>'
      else
        youtube_id = $(e.srcElement).data("youtube-id")
        if youtube_id == undefined
          html = '
          <video id="video_' + $(e.srcElement).data("id") + '" class="video-js vjs-default-skin" controls
          preload="auto" width="390" height="300" data-setup="{}">
            <source src="http://s3.amazonaws.com/' + $(e.srcElement).data("bucket") + '/' + $(e.srcElement).data("id") + '.mp4" type=\'video/mp4\'>
            <source src="http://s3.amazonaws.com/' + $(e.srcElement).data("bucket") + '/' + $(e.srcElement).data("id") + '.webm" type=\'video/webm\'>
          </video>'
        else
          html = '
          <iframe width="390" height="300"
          src="http://www.youtube.com/embed/' + youtube_id + '" 
          frameborder="0" allowfullscreen></iframe>'
      unless $(".content_form:visible").hasClass("dont-publish")
        console.log "publishable"
        $(".content_form:visible .wysiwyg").wysiwyg('insertHtml', html)
      else
        console.log "unpublishable"
        e.preventDefault()
        return false
      true
  $(".content_form:first").siblings(".content_form").hide()
  $(".tab-pane").droppable
    drop: (e, ui) ->
      if ($(this).is(".photos") and $(e.srcElement).hasClass("photo")) or ($(this).is(".videos") and $(e.srcElement).hasClass("video"))
        img_src = $(e.srcElement).attr("src").replace("s800", "s64-c")
        html = '<li class="span1"><i class="icon-remove icon-white" title="remove"></i><a href="#" class="thumbnail"><img class="photo" src="'+img_src+'"/></a></li>'
        tmp_chkbx = $(this).find(".tmp input").clone()
        $(tmp_chkbx).prop("checked", true).attr("value", $(e.srcElement).data("id"))
        if $(this).find("p").hasClass("empty")
          $(this).find("p.empty").remove()
          $(this).append('<ul class="thumbnails"></ul>')
        if $(this).is(".photos")
          $(this).find(".thumbnails").append(html)
          $(this).find(".thumbnails .thumbnail").last().parent().append(tmp_chkbx)
        else if $(this).is(".videos")
          $(this).find(".thumbnails").html(html)
          $(this).find(".thumbnails .thumbnail").last().parent().append(tmp_chkbx)
        true
      else
        false
  true
  
  $(".post-settings .pattern").on 'click', (e) ->
    console.log "clicked"
    $(".post-settings .pattern").removeClass("active")
    $(this).addClass("active")
    terminals =  $(this).data('terminals')
    $("#social_connections.connections input[type=checkbox]").attr("checked", null)
    $("#social_connections.connections input[type=checkbox]").each(
      ->
        if terminals.indexOf($(this).data("terminal-id")) > -1
          $(this).click()
    )
    $(".post-settings button:first").text($(this).text())
    $(".post-settings.create").hide()
    return false
    

