class Author::MediaBucketWidget < Apotomo::Widget

  def display(buckets, shard)
    @videos=buckets[:videos].nil? ? [] : buckets[:videos]
    @audios=buckets[:audios].nil? ? [] : buckets[:audios]
    @albums=buckets[:albums].nil? ? [] : buckets[:albums]
    @shard = shard
    render
  end

  def gallery(prefix, galleries)
    @video_gallery=galleries[:video_gallery] if (galleries[:video_gallery])
    @audio_gallery=galleries[:audio_gallery] if (galleries[:audio_gallery])
    @photo_gallery=galleries[:photo_gallery] if (galleries[:photo_gallery])
    @prefix=prefix.to_s
    @pprefix=prefix.to_s.parameterize
    render
  end
end
