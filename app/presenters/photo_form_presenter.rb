class PhotoFormPresenter < BasePresenter
  presents :photo

  def summary
    form_field(:summary, f.text_area(:summary, :class => "span8", :size => "20x5"))
  end
  
  def album_id(id)
    f.hidden_field(:album_id, value: id)
  end
  
  def title
    form_field(:title, f.text_field(:title))
  end

  def file
    form_field(:file, f.file_field(:file))
  end
end