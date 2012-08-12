class Author::AudiosController < Author::SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]
  before_filter :find_audio_album

  def index

    @audios = @audio_album.audios.default_order
    respond_to { |format|
      format.html
      format.json { render json: @audios }
    }
  end

  def show
    @audio = @audio_album.audios.find(params[:id])

    respond_to { |format|
      format.html # show.html.erb
      format.json { render json: @audio }
    }
  end

  def new
    @audio = @audio_album.audios.new
    @audio_languages = []
    @current_shard.shard_languages.each {|lang|
      @audio_languages << AudioLanguage.new(shard_language_id: lang.id)
    }
    @form_legend = t('author.audio.form_legend.new')

    respond_to { |format|
      format.html { render :form }
      format.json { render json: @audio }
    }
  end

  def edit
    @audio = @audio_album.audios.find(params[:id]) || not_found
    @audio_languages = @audio.audio_languages
    @form_legend = t('author.audio.form_legend.edit')
    respond_to { |format|
      format.html { render :form }
    }
  end

  def create
    @audio = Audio.new(params[:audio])
    @audio.audio_album = @audio_album
    @form_legend = t('author.audio.form_legend.new')
    debugger

    respond_to do |format|
      if params[:sample]
        unless [".mp3", ".aac", ".wma", ".ogg"].include? File.extname(params[:sample].original_filename)
          @audio.errors.add(:file, "Wrong file type")
          flash[:error_notice] = "Wrong file type"
        end
      end
      if @audio.errors.empty? && @audio.save
        format.html {
          redirect_to author_audio_album_audios_path(@audio_album), notice: 'Audio was successfully uploaded.'
        }
        format.json { render json: @audio, status: :created, location: @audio }
      end
    end
  end

  # PUT /audios/1
  # PUT /audios/1.json
  def update
    @audio = @audio_album.audios.find(params[:id]) || not_found
    @audio_languages = @audio.audio_languages
    @form_legend = t('author.audio.form_legend.edit')

    respond_to { |format|
      if @audio.update_attributes(params[:audio])
        format.html { redirect_to author_audio_album_audios_path(@audio_album), notice: 'Audio was successfully updated.'}
        format.json { head :ok }
      else
        format.html { render :form }
        format.json { render json: @audio.errors, status: :unprocessable_entity }
      end
    }
  end

  # DELETE /audios/1
  # DELETE /audios/1.json
  def destroy
    @audio = @audio_album.audios.find(params[:id]) || not_found
    @audio.destroy

    respond_to { |format|
      format.html { redirect_to author_audio_album_audios_path(@audio_album), notice: 'Video was successfully deleted.' }
      format.json { head :ok }
    }
  end

private

  def shard_languages
    @shard_languages = @current_shard.shard_languages
  end
  
  def find_audio_album
    @audio_album = AudioAlbum.find_by_id(params[:audio_album_id])
  end
end
