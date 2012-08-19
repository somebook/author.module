module Author
class AudiosController < SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]

  def index
    @audios = audio_album.audios.default_order
  end

  def new
    @audio = audio_album.audios.new
    @audio_languages = @current_shard.shard_languages.map { |shard_language|
      @AudioLanguage.new(shard_language_id: shard_language.id)
    }
    @form_legend = t("author.audio.form_legend.new")

    render :form
  end

  def edit
    @audio = audio_album.audios.find(params[:id]) || not_found
    @audio_languages = @audio.audio_languages
    @form_legend = t("author.audio.form_legend.edit")

    render :form
  end

  def create
    @audio = Audio.new(params[:audio])
    @audio.audio_album = audio_album
    @form_legend = t("author.audio.form_legend.new")

    # TODO: All validations MUST be in models
    if params[:sample]
      unless %w[ .mp3 .aac .wma .ogg ].include? File.extname(params[:sample].original_filename)
        @audio.errors.add(:file, "Wrong file type")
        flash[:error_notice] = "Wrong file type"
      end
    end

    if @audio.errors.empty? && @audio.save
      redirect_to author_audio_album_audios_path(audio_album), notice: t("author.audio.notice.create_success")
    else
      render :form
    end
  end

  def update
    @audio = audio_album.audios.find(params[:id]) || not_found
    @audio_languages = @audio.audio_languages
    @form_legend = t("author.audio.form_legend.edit")

    if @audio.update_attributes(params[:audio])
      redirect_to author_audio_album_audios_path(audio_album), notice: t("author.audio.notice.update_success")
    else
      render :form
    end
  end

  def destroy
    @audio = audio_album.audios.find(params[:id]) || not_found
    @audio.destroy

    redirect_to audio_album_audios_path(audio_album), notice: t("author.audio.notice.delete_success")
  end

private

  def audio_album
    @audio_album ||= AudioAlbum.find_by_id(params[:audio_album_id])
  end

end
end
