module Author
class AlbumsController < SpaceController
  load_and_authorize_resource
  before_filter :init_picasa
  before_filter :check_picasa_auth, except: [:index, :authorize]

  def index
  	@url = picasa_authorization_url if @picasa.nil?
    @albums = @current_shard.albums.order('id DESC').paginate(page: params[:page], per_page: 20)
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
    @album.access = (params[:album][:access] == "public")

    if @album.save_to_db_and_picasa(@picasa, current_user, @current_shard)
      redirect_to albums_path, notice: t("author.album.notice.create_success")
    else
      redirect_to new_album_path, error: t("author.album.notice.create_fail")
    end
  end

  def destroy
    @album = Album.find_by_id(params[:id])

    if @album.destroy_from_db_and_picasa(@picasa)
      redirect_to albums_path, notice: t("author.album.notice.delete_success")
    else
      redirect_to albums_path, error: t("author.album.notice.delete_success")
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
      redirect_to albums_path, notice: t("author.album.notice.update_success")
    else
      redirect_to edit_album_path(@album), error: t("author.album.notice.delete_fail")
    end
  end

  def sync
    current_user.sync_albums(@picasa, @current_shard)
    # TODO: переделать на delayed_jobs
    redirect_to albums_path, notice: t("author.album.notice.sync_success")
  end

  def authorize
    if Picasa.token_in_request?(request)
      begin
        picasa = Picasa.authorize_request(request)
        acc = Account.find_by_provider_and_uid_and_shard_id("picasa", picasa.user.user.to_s, @current_shard.id)
        if acc
          redirect_to settings_path, error: "Account already exists."
        else
          account = Account.create!(
            shard_id: @current_shard.id,
            provider: "picasa",
            token: picasa.token,
            uid: picasa.user.user.to_s,
            name: picasa.user.nickname,
            user_id: current_user.id,
            service_id: Service.find_by_code("picasa").id
          )
          current_user.sync_albums(picasa, @current_shard)
          redirect_to settings_path, notice: t("author.album.notice.picasa_auth_success")
        end
      rescue
        redirect_to settings_path, error: t("author.album.notice.picasa_auth_fail")
      end
    end
  end

  def hidden
    @album = Album.find_by_shard_id_and_id(@current_shard.id, params[:album_id]) || not_found
    @album.update_attribute(:hidden, !@album.hidden)

    action = @album.hidden ? "show" : "hide"
    redirect_to albums_path, notice: t("author.album.notice.#{action}_success")
  end

private

  def check_picasa_auth
    redirect_to albums_path if @picasa.nil?
  end
  
  def init_picasa
    picasa_acc = Account.where(provider: "picasa", shard_id: @current_shard.id).first
    @picasa = picasa_acc.nil? ? nil : Picasa.new(picasa_acc.token)
  end
  
  def set_section_class
    @section_class = "albums"
  end

end
end
