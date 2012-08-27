class AudioAlbumFormPresenter < BasePresenter
  presents :audio_album
  
  def name
    form_field(:name, f.text_field(:name))
  end
  
  def description
    form_field(:description, f.text_area(:description))
  end

  def cover
    form_field(:cover, f.file_field(:cover))
  end
end
