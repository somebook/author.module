class AudioFormPresenter < BasePresenter
  presents :audio
  
  def name
    form_field(:name, f.text_field(:name))
  end
  
  def sample
    form_field("Sample", f.file_field(:sample))
  end
end
