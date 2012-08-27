class AlbumFormPresenter < BasePresenter
  presents :album

  def title
    form_field(:title, f.text_field(:title))
  end

  def summary
    form_field(:summary, f.text_area(:summary, :class => "span8", :size => "20x5"))
  end

  def access
    form_multiple(:access, [
        [ f.radio_button(:access, :public, checked: true), "Public" ],
        [ f.radio_button(:access, :private), "Private" ]
      ]
    )
  end
end