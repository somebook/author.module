module Author
class EventsController < SpaceController
  load_and_authorize_resource
  cache_sweeper :event_sweeper

  before_filter :shard_languages, except: [:publish,:destroy,:show]
  before_filter :assets, only: [:new, :edit]

  has_widgets do |root|
    root <<  widget("author/media_bucket",:media_bucket) do |bucket|
      bucket << widget("author/video_bucket", :video_bucket)
      bucket << widget("author/album_bucket", :album_bucket)
      bucket << widget("author/audio_bucket", :audio_bucket)
    end
  end

  def index
    @events = @current_shard.events.order('starts_at DESC')
  end

  def new
    @event = Event.new(
      infos: @shard_languages.map{ |shard_language|
        EventInfo.new(shard_language_id: shard_language.id)
      }
    )
    @form_legend = t("author.event.form_legend.new")

    render :form
  end

  def edit
    @event = @current_shard.events.find(params[:id]) || not_found
    @form_legend = t("author.event.form_legend.edit")

    render :form
  end

  def create
    params[:event][:user_id] = current_user.id
    params[:event][:starts_at] = params[:starts_at_date] + " " + params[:starts_at_time]
    params[:event][:without_time] = (params[:starts_at_time].nil? || params[:starts_at_time].match(/\d\d:\d\d/).nil?)
    params[:event][:infos_attributes].each do |info|
      info[1][:tickets_url] = nil if info[1][:tickets_url].nil? || info[1][:tickets_url].strip == ""
    end

    @event = Event.new(params[:event])
    @event.shard = @current_shard
    @form_legend = t("author.event.form_legend.new")

    if @event.save
      redirect_to events_path, notice: t("author.event.notice.create_success")
    else
      render :form
    end
  end

  def update
    params[:event][:user_id] = current_user.id
    params[:event][:starts_at] = params[:starts_at_date] + " " + params[:starts_at_time]
    params[:event][:without_time] = (params[:starts_at_time].nil? || params[:starts_at_time].match(/\d\d:\d\d/).nil?)
    params[:event][:infos_attributes].each do |info|
      info[1][:tickets_url] = nil if info[1][:tickets_url].nil? || info[1][:tickets_url].strip == ""
    end

    @event = @current_shard.events.find(params[:id]) || not_found
    @form_legend = t("author.event.form_legend.edit")

    if @event.update_attributes(params[:event])
      redirect_to events_path, notice: t("author.event.notice.update_success")
    else
      render :form
    end
  end

  def destroy
    @event = @current_shard.events.find(params[:id]) || not_found
    @event.destroy

    redirect_to events_path, notice: t("author.event.notice.delete_success")
  end

  private

  def shard_languages
    @shard_languages = @current_shard.shard_languages
  end

  def assets
    @albums = @current_shard.albums
    @videos = @current_shard.videos.default_order
    @audio_albums = @current_shard.audio_albums.default_order
  end
  
  def set_section_class
    @section_class = "events"
  end

end
end
