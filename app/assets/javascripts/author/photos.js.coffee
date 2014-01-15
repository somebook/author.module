jQuery ->
  $("#photos li.thumbnail").popover()
  $('#new_photo').fileupload
    dataType: 'script'
    add: (e, data) ->
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        data.context = $(tmpl("template-upload", file))
        $("#new_photo").append(data.context)
        data.submit()
      else
        alert("#{file.name} is not a gif, jpeg or png image file")
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
        if progress == 100
          data.context.remove()

  $("#photos").on 'click', 'li.thumbnail .photo_link', (e) ->
    $(this).popover('toggle')
    e.preventDefault()

  $("body").on 'click', '.popover-close', (e) ->
    $("li.thumbnail[data-photo-id=" + $(this).data("photo-id") + "] .photo_link").popover("hide")
    e.preventDefault()