class Author::VideoBucketWidget < Apotomo::Widget

  def display(videos, shard)
    @videos=videos
    @shard = shard
    render
  end
end
