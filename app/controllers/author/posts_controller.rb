class Author::PostsController < Author::SpaceController
  load_and_authorize_resource
  cache_sweeper :post_sweeper

  before_filter :shard_languages, :except => [:publish,:destroy,:show]
  before_filter :assets, only: [:new, :edit, :update]

  def index
    # params[:stream]='official' unless params[:stream]
    @posts = @current_shard.posts.with_stream(params[:stream]).order('created_at DESC').paginate(page: params[:page],per_page: 20)
    respond_to do |format|
      format.html { render 'index' }# index.html.erb
      format.json { render json: @posts }
    end
  end

  def blog
    params[:stream] = "personal"
    index
  end

  def news
    params[:stream] = "official"
    index
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new(:stream => params[:stream])
    @form_legend = t("author.post.form_legend.new")
    @shard_languages.each do |c|
      cnt = Content.new(is_enabled: true)
      cnt.shard_language = c
      @post.contents << cnt
    end
    @post.contents.each do |content|
      content.shard_language.accounts.stream(Account::STREAMS[params[:stream].to_i]).each do |acc|
        acc.terminals.each do |terminal|
          cnt = SocialContent.new
          cnt.content = content
          cnt.terminal = terminal
          content.social_contents << cnt
        end
      end
    end

    respond_to do |format|
      format.html { render :form }
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = @current_shard.posts.find(params[:id]) || not_found
    @form_legend = t("author.post.form_legend.edit")

    respond_to do |format|
      format.html { render :form }
    end
  end

  # POST /posts
  # POST /posts.json
  def create
    validated_shard_language = true
    params[:post][:publish_at] = params[:publish_at_date] + " " + params[:publish_at_time]
    params[:post][:contents_attributes].each do |k,ca|
      ca[:is_enabled]=ca[:is_enabled] ? true : false
    end
    params[:post][:contents_attributes].each do |k,ca|
      unless @current_shard.shard_languages.exists?(ca[:shard_language_id].to_s)
        validated_shard_language=false
      end
    end

    if validated_shard_language
      #params[:post][:user_id] = current_user.id
      pp=post_params
      pp[:post][:user_id]=current_user.id
      @post= Post.new(pp[:post])
      @post.contents.each { |c|
        c.photos = [] if c.gallery == "videos"
        c.videos = [] if c.gallery == "photos"
      }
      @post.shard=@current_shard
      @post.user=current_user
      @form_legend = t("author.post.form_legend.new")
      if params[:post][:contents_attributes]
         params[:post][:contents_attributes].each do |k, v|
           v[:status] ||= []
           v[:photo_ids] ||= []
           v[:video_ids] ||= []
         end
      end

      respond_to do |format|
        if @post.save
          format.html { redirect_to (@post.stream_name == :personal ? blog_author_posts_path : news_author_posts_path) , notice: 'Post was successfully created.' }
          format.json { render json: @post, status: :created, location: @post }
        else
          format.html { render :form }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    params[:post][:publish_at] = params[:publish_at_date] + " " + params[:publish_at_time] if params[:publish_at_date]
    params[:post][:user_id] = current_user.id
    @post = @current_shard.posts.find(params[:id]) || not_found
    @form_legend = t("author.post.form_legend.edit")
    validated=true
    if(params[:post][:contents_attributes])
      params[:post][:contents_attributes].each do |k, v|
        unless @current_shard.shard_languages.exists?(v[:shard_language_id].to_s)
          validated = false
        end
        params[:post][:contents_attributes].each do |k,ca|
          ca[:is_enabled]=ca[:is_enabled] ? true : false
        end
        v[:photo_ids] ||= []
        v[:video_ids] ||= []
        if v[:gallery] == "photos"
          v["video_ids"] = []
        elsif v[:gallery] == "videos"
          v["photo_ids"] = []
        end
      end
    end

    respond_to do |format|
      if validated &&  @post.update_attributes(post_params[:post])
        job = Delayed::Job.find_by_id(@post.job_id)
        job.destroy if job
        if @post.publish_at && @post.publish_at > Time.now
          @post.delay! unless @post.delayed?
          job = Delayed::Job.enqueue(PublishingJob.new(@current_shard, @post), 0, @post.publish_at) unless Rails.env.test?
          @post.update_attribute(:job_id, job.id)
        else
          @post.draft! unless @post.published?
          @post.update_attribute(:job_id, nil)
        end
        format.html { redirect_to (@post.stream_name == :personal ? blog_author_posts_path : news_author_posts_path), notice: 'Post was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :form }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = @current_shard.posts.find(params[:id]) || not_found
    stream=@post.stream_name
    job = Delayed::Job.find_by_id(@post.job_id)
    job.destroy if job
    @post.destroy

    respond_to do |format|
      format.html { redirect_to (stream == :personal ? blog_author_posts_path : news_author_posts_path), notice: 'Post was successfully deleted.' }
      format.json { head :ok }
    end
  end

  # GET /posts/1/publish
  def publish
    @post = @current_shard.posts.find(params[:post_id]) || not_found
    if @post.publish_at && @post.publish_at > Time.now && !(params[:now] && params[:now] == "true")
      @post.delay!
      job = Delayed::Job.enqueue(PublishingJob.new(@current_shard, @post), 0, @post.publish_at) unless Rails.env.test?
      @post.update_attribute(job_id: job.id)
    else
      begin
        job = Delayed::Job.find_by_id(@post.job_id)
        job.destroy if job
        @post.publish!
        @post.save
      rescue TerminalPublishingError => e
        if(e.user_note.blank?)
          flash[:error_notice]=e.terminal.to_s+" : "+I18n.t("author.post.reconnect_terminal_error")
        else
          flash[:error_notice]=e.terminal.to_s+" : "+e.user_note
        end

        flash[:error_notice_ext]=e.terminal.to_s+" >>> "+I18n.t("author.post.reconnect_terminal_error") + " (#{e}: #{e.parent})"
      end
    end
    render partial: 'post', content_type: "text/html"
  end

  # GET /posts/1/sticky
  def sticky
    @post = @current_shard.posts.find(params[:post_id]) || not_found
    if @post.sticky?
      @current_shard.posts.where('sticky = ?', true).each{ |post| post.update_attribute(:sticky, false) }
      @post.update_attribute(:sticky, false)
    else
      @current_shard.posts.where('sticky = ?', true).each{ |post| post.update_attribute(:sticky, false) }
      @post.update_attribute(:sticky, true)
    end
    # redirect_to author_posts_path, notice: "Post was succesfully #{'un' unless @post.sticky}sticked."
    render nothing: true
  end

private

  def shard_languages
    @shard_languages = @current_shard.shard_languages
  end

  def assets
    @albums = @current_shard.albums
    @videos = @current_shard.videos.default_order
  end

  def post_params
    #, :user_id, :shard_id
    p=params.permit(post: [
                    :stream,
                    :publish_at,
                    :created_at,
                    :publish_at,
                    :is_archive,
                    :contents_attributes])
    #ap p
    #ap params
    # p
  end
end
