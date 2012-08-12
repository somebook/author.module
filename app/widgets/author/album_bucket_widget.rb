class Author::AlbumBucketWidget < Apotomo::Widget

  def display(albums)
    @albums=albums
    render
  end

end
