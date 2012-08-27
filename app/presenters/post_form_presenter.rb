class PostFormPresenter < BasePresenter
  presents :post

  def stream
    f.hidden_field(:stream)
  end

  def tags
    #f.tags_list(:tags)
  end
  def archive
  	form_field(:is_archive, f.check_box(:is_archive))
  end
end
