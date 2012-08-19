module Author
class AudioAlbumsController < SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]

  def index
    @audio_albums = @current_shard.audio_albums.default_order
  end

  def new
    @audio_album = AudioAlbum.new(shard: @current_shard)
    @form_legend = t("author.audio_album.form_legend.new")

    render :form
  end

  def edit
    @audio_album = @current_shard.audio_albums.find(params[:id]) || not_found
    @form_legend = t("author.audio_album.form_legend.edit")

    render :form
  end

  def create
    @audio_album = AudioAlbum.new(params[:audio_album])
    @audio_album.shard = @current_shard
    @form_legend = t("author.audio_album.form_legend.new")
    debugger

    if @audio_album.errors.empty? && @audio_album.save
      redirect_to audio_albums_path, notice: t("author.audio_album.notice.create_success")
    end
  end

  def update
    @audio_album = @current_shard.audio_albums.find(params[:id]) || not_found
    @form_legend = t("author.audio_album.form_legend.edit")

    if @audio_album.update_attributes(params[:audio_album])
      redirect_to audio_albums_path, notice: t("author.audio_album.notice.update_success")
    else
      render :form
    end
  end

  def destroy
    @audio_album = @current_shard.audio_albums.find(params[:id]) || not_found
    @audio_album.destroy

    redirect_to audio_albums_path, t("author.audio_album.notice.delete_success")
  end

end
end
