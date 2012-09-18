class PostFormPresenter < BasePresenter
  presents :post

  def stream
    f.hidden_field(:stream)
  end

  def tags
    #f.tags_list(:tags)
  end
end
