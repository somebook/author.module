module Author
class PhotosController < PicasaController

  def index
    @photos = album.photos
  end

  def new
    @photo = Photo.new
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
      redirect_to album_photos_path(album), notice: t("author.photo.notice.create_success")
    else
      redirect_to new_album_photo_path(album), error: t("author.photo.notice.create_fail")
    end
  end

  def destroy
    @photo = Photo.find_by_id(params[:id])

    if @photo.destroy_from_db_and_picasa(@picasa)
      redirect_to album_photos_path(album), notice: t("author.photo.notice.delete_success")
    else
      redirect_to album_photos_path(album), error: t("author.photo.notice.delete_fail")
    end
  end

  def sync
    album.sync_photos(@picasa)

    # TODO: переделать на delayed_jobs
    redirect_to album_photos_path(album), notice: t("author.photo.notice.sync_success")
  end

private

  def album
    @album ||= Album.find_by_id(params[:album_id])
  end

end
end
