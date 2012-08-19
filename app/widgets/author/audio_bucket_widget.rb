class Author::AudioBucketWidget < Apotomo::Widget

  def display(audio_albums)
    @audio_albums=audio_albums
    render
  end

end
