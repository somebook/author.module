require 'ruby_picasa'
module Author
class PhotosController < SpaceController
  before_filter :init_picasa

  def index
    @photos = album.photos
    @form_legend = t("author.album.photo.form_legend.new")
  end

  def new
    @photo = Photo.new
    album
    @form_legend = t("author.album.photo.form_legend.new")

    render :form
  end

  def create
    @photo = Photo.new(
      summary: params[:photo][:summary],
      album_id: params[:photo][:album_id],
      title: params[:photo][:title]
    )

    if @photo.save_to_db_and_picasa(@picasa, params[:photo][:file])
      # redirect_to album_photos_path(album), notice: t("author.photo.notice.create_success")
      respond_to do |format|
        format.js
      end
    else
      # redirect_to new_album_photo_path(album), error: t("author.photo.notice.create_fail")
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @photo = Photo.find_by_id(params[:id])

    if @photo.destroy_from_db_and_picasa(@picasa)
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def sync
    album.sync_photos(@picasa)

    # TODO: переделать на delayed_jobs
    redirect_to album_photos_path(album), notice: t("author.photo.notice.sync_success")
  end

private

  def album
    @album = Album.find_by_id(params[:album_id])
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
