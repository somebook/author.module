class VideoFormPresenter < BasePresenter
  presents :video
  
  def stream
    f.hidden_field :stream, value: @object.stream
  end
  
  def token hash
    hidden_field_tag :token, hash
  end
  
  def youtube
    form_field(:youtube, f.check_box(:youtube))
  end

  def title
    form_field(:title, f.text_field(:title))
  end
  
  def desc
    form_field(:desc, f.text_area(:desc, rows: 4))
  end
  
  def language_id languages
    form_field(:language_id, f.select(:language_id, languages.collect{ |l| [ l.name, l.id ] }))
  end
  
  def youtube_id
    form_field(:youtube_id, f.text_field(:youtube_id))
  end
  
  def categories
    form_multiple(:categories, [
        [ f.radio_button(:categories, :people, checked: @object.categories?(:people)), h.t('author.video.category.people') ],
        [ f.radio_button(:categories, :music, checked: @object.categories?(:music)), h.t('author.video.category.music') ],
        [ f.radio_button(:categories, :misc, checked: @object.categories?(:misc)), h.t('author.video.category.misc') ]
      ]
    )
  end
  
  def file
    form_field("File", file_field_tag(:file))
  end
end
