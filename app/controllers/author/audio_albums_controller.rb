class Author::AudioAlbumsController < Author::SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]

  def index
    @audio_albums = @current_shard.audio_albums.default_order
    respond_to { |format|
      format.html
      format.json { render json: @audio_albums }
    }
  end

  def show
    @audio_album = @current_shard.audio_albums.find(params[:id])

    respond_to { |format|
      format.html # show.html.erb
      format.json { render json: @audio_album }
    }
  end

  def new
    @audio_album = AudioAlbum.new
    @form_legend = t("author.audio_album.form_legend.new")
    @audio_album.shard = @current_shard

    respond_to { |format|
      format.html { render :form }
      format.json { render json: @audio_album }
    }
  end

  def edit
    @audio_album = @current_shard.audio_albums.find(params[:id]) || not_found
    @form_legend = t("author.audio_album.form_legend.edit")
    respond_to { |format|
      format.html { render :form }
    }
  end

  def create
    @audio_album = AudioAlbum.new(params[:audio_album])
    @audio_album.shard = @current_shard
    @form_legend = t("author.audio_album.form_legend.new")
    debugger

    respond_to do |format|
      if @audio_album.errors.empty? && @audio_album.save
        format.html {
          redirect_to audio_albums_path, notice: 'Audio album was successfully uploaded.'
        }
        format.json { render json: @audio_album, status: :created, location: @audio_album }
      end
    end
  end

  # PUT /audio_albums/1
  # PUT /audio_albums/1.json
  def update
    @audio_album = @current_shard.audio_albums.find(params[:id]) || not_found
    @form_legend = t("author.audio_album.form_legend.edit")

    respond_to { |format|
      if @audio_album.update_attributes(params[:audio_album])
        redirect_to audio_albums_path, notice: 'Audio was successfully updated.'
        format.json { head :ok }
      else
        format.html { render :form }
        format.json { render json: @audio_album.errors, status: :unprocessable_entity }
      end
    }
  end

  # DELETE /audio_albums/1
  # DELETE /audio_albums/1.json
  def destroy
    @audio_album = @current_shard.audio_albums.find(params[:id]) || not_found
    @audio_album.destroy

    respond_to { |format|
      format.html { redirect_to audio_albums_path, notice: 'Video was successfully deleted.' }
      format.json { head :ok }
    }
  end

private

  def shard_languages
    @shard_languages = @current_shard.shard_languages
  end
end
