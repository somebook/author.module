class Author::EventsController < Author::SpaceController
  load_and_authorize_resource
  cache_sweeper :event_sweeper
  # GET /events
  # GET /events.json
  before_filter :shard_languages, :except => [:publish,:destroy,:show]
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
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = @current_shard.events.find(params[:id]) || not_found
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    @form_legend = translate('author.event.form_legend.new')
    @shard_languages.each{ |c| @event.infos << EventInfo.new(shard_language_id: c.id) }

    respond_to do |format|
      format.html { render :form }
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = @current_shard.events.find(params[:id]) || not_found
    @form_legend = translate('author.event.form_legend.edit')
    respond_to do |format|
      format.html { render :form }
    end
  end

  # POST /events
  # POST /events.json
  def create
    params[:event][:user_id] = current_user.id
    params[:event][:starts_at] = params[:starts_at_date] + " " + params[:starts_at_time]
    params[:event][:without_time] = (params[:starts_at_time].nil? || params[:starts_at_time].match(/\d\d:\d\d/).nil?) ? true : false
    params[:event][:infos_attributes].each do |info|
      info[1][:tickets_url] = nil if info[1][:tickets_url].nil? || info[1][:tickets_url].strip == ""
    end
    
    @event = Event.new(params[:event])
    @event.shard=@current_shard
    @form_legend = translate('author.event.form_legend.new')
    respond_to do |format|
      if @event.save
        format.html { redirect_to author_events_url, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render :form }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    params[:event][:user_id] = current_user.id
    params[:event][:starts_at] = params[:starts_at_date] + " " + params[:starts_at_time]
    params[:event][:without_time] = (params[:starts_at_time].nil? || params[:starts_at_time].match(/\d\d:\d\d/).nil?) ? true : false
    params[:event][:infos_attributes].each do |info|
      info[1][:tickets_url] = nil if info[1][:tickets_url].nil? || info[1][:tickets_url].strip == ""
    end

    @event = @current_shard.events.find(params[:id]) || not_found
    @form_legend = translate('author.event.form_legend.edit')

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to author_events_url, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :form }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = @current_shard.events.find(params[:id]) || not_found
    @event.destroy
    respond_to do |format|
      format.html { redirect_to author_events_url, notice: 'Event was successfully deleted.' }
      format.json { head :ok }
    end
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
end
