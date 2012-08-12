class Author::PhotosController < Author::PicasaController
  before_filter :init_album
  
  def index
    @photos = @album.photos
  end
  
  def new
    @photo = Photo.new
    @form_legend = t('author.album.photo.form_legend.new')
    render :form
  end
  
  def create
    @photo = Photo.new(summary: params[:photo][:summary], album_id: params[:photo][:album_id], title: params[:photo][:title])
    if @photo.save_to_db_and_picasa(@picasa, params[:photo][:file])
      redirect_to author_album_photos_path(@album), notice: 'Photo successfully uploaded.'
    else
      redirect_to new_author_album_photo_path(@album), error: 'Photo uploading fails.'
    end
  end
  
  def destroy
    @photo = Photo.find_by_id(params[:id])
    if @photo.destroy_from_db_and_picasa(@picasa)
      redirect_to author_album_photos_path(@album), notice: 'Album was successfully deleted.'
    else
      redirect_to author_album_photos_path(@album), error: 'There were errors while deleting album.'
    end
  end
  
  def sync
    @album.sync_photos(@picasa)
    #TODO: переделать на delayed_jobs
    redirect_to author_album_photos_path(@album), notice: "Photos was successfully synchronized."
  end
  
  private
  
  def init_album
    @album = Album.find_by_id(params[:album_id])
  end
end
