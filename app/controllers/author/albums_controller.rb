class Author::AlbumsController < Author::PicasaController
  load_and_authorize_resource
  before_filter :check_picasa_auth, :except => [:index, :authorize]

  def index
  	@url = Picasa.authorization_url(authorize_author_albums_url) if @picasa.nil?
    @albums = current_user.albums.order('id DESC')
    #ap @picasa.create_album(:title => 'test album')
  end

  def show
    @album = Album.find_by_id(params[:id])
  end

  def new
    @album = Album.new
    @form_legend = t("author.album.form_legend.new")
    render :form
  end

  def create
    @album = Album.new(params[:album])
    @album.access = params[:album][:access] == "public" ? true : false
    if @album.save_to_db_and_picasa(@picasa, current_user, @current_shard)
      redirect_to albums_path, notice: 'Album was successfully created.'
    else
      redirect_to new_album_path, error: 'Album creation fails.'
    end
  end

  def destroy
    @album = Album.find_by_id(params[:id])
    if @album.destroy_from_db_and_picasa(@picasa)
      redirect_to albums_path, notice: 'Album was successfully deleted.'
    else
      redirect_to albums_path, error: 'There were errors while deleting album.'
    end
  end

  def edit
    @album = Album.find_by_id(params[:id])
    @form_legend = t("author.album.form_legend.edit")
    render :form
  end

  def update
    @album = Album.find_by_id(params[:id])
    if @album.update_in_db_and_picasa(@picasa, params[:album])
      redirect_to albums_path, notice: 'Album was successfully updated.'
    else
      redirect_to edit_album_path(@album), error: 'There were errors while deleting album.'
    end
  end

  def sync
    current_user.sync_albums(@picasa, @current_shard)
    #TODO: переделать на delayed_jobs
    redirect_to albums_path, notice: "Albums was successfully synchronized."
  end

  def authorize
    if Picasa.token_in_request?(request)
      begin
        picasa = Picasa.authorize_request(request)
        Account.create!(shard_id: @current_shard.id, provider: 'picasa', token: picasa.token, nickname: picasa.user.nickname, user_id: current_user.id)
        redirect_to albums_path, notice: 'Picasa authorization complete.'
      rescue
        redirect_to albums_path, error: 'Picasa authorization fail.'
      end
    end
  end

  def hidden
    @album = Album.find_by_shard_id_and_id(@current_shard.id, params[:album_id]) || not_found
    @album.hidden ? @album.update_attribute(:hidden, false) : @album.update_attribute(:hidden, true)
    redirect_to albums_path, notice: "Album was successfully #{'un' unless @album.hidden}hidden."
  end

  private

  def check_picasa_auth
    redirect_to albums_path if @picasa.nil?
  end

end
