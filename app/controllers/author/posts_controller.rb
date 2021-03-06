module Author
class PostsController < SpaceController
  load_and_authorize_resource
  cache_sweeper :post_sweeper

  before_filter :shard_languages, except: [:publish, :destroy, :show]
  before_filter :assets, only: [:new, :edit, :update]
  before_filter :publication_patterns, only: [:new, :edit, :update]

  def index
    @patterns = @current_shard.publication_patterns
    @posts = @current_shard.posts
      .with_stream(params[:stream])
      .order('created_at DESC')
      .paginate(page: params[:page], per_page: 20)

    render :index
  end

  def blog
    params[:stream] = "personal"
    @section_class = "blog"
    index
  end

  def news
    params[:stream] = "official"
    @section_class = "news"
    index
  end

  def new
    @section_class = params[:stream] == "1" ? "blog" : "news"
    @post = Post.new(
      stream: params[:stream],
      contents: @shard_languages.map{ |shard_language|
        Content.new(
          is_enabled: true,
          shard_language: shard_language
        )
      }
    )
    @post.contents.each do |content|
      Terminal.joins(:shard_languages).where('shard_language_id = ?', content.shard_language.id).each do |terminal|
        next unless terminal.streams.include? Account::STREAMS[params[:stream].to_i]
        cnt = SocialContent.new(
          content: content,
          terminal: terminal
        )
        content.social_contents << cnt
      end
    end

    @form_legend = t("author.post.form_legend.new")

    render :form
  end

  def edit
    @post = @current_shard.posts.find(params[:id]) || not_found
    params[:stream] = @post.stream
    @section_class = @post.stream == 1 ? "blog" : "news"
    @form_legend = t("author.post.form_legend.edit")

    render :form
  end

  def create
    validated_shard_language = true
    params[:post][:publish_at] = params[:publish_at_date] + " " + params[:publish_at_time]
    params[:post][:created_at] = params[:created_at_date] + " " + params[:created_at_time]
    params[:post][:contents_attributes].each do |key, contents_attribute|
      contents_attribute[:is_enabled] = !!contents_attribute[:is_enabled]
      unless @current_shard.shard_languages.exists?(contents_attribute[:shard_language_id].to_s)
        validated_shard_language = false
      end
    end

    if validated_shard_language
      post_params_clone = post_params.clone
      post_params_clone[:post][:user_id] = current_user.id

      @post= Post.new(params[:post])
      @post.contents.each { |content|
        content.photos = [] if content.gallery == "videos"
        content.videos = [] if content.gallery == "photos"
        ap content.social_contents
      }

      @post.shard = @current_shard
      @post.user = current_user

      if params[:post][:contents_attributes]
        params[:post][:contents_attributes].each do |key, values|
          values[:status] ||= []
          values[:photo_ids] ||= []
          values[:video_ids] ||= []
        end
      end

      @form_legend = t("author.post.form_legend.new")
      redirect_path = @post.stream_name == :personal ? blog_posts_path : news_posts_path
      if @post.save
        redirect_to redirect_path, notice: t("author.post.notice.create_success")
      else
        render :form
      end
    end
  end

  def update
    if params[:publish_at_date]
      params[:post][:publish_at] = params[:publish_at_date] + " " + params[:publish_at_time]
    end
    params[:post][:created_at] = params[:created_at_date] + " " + params[:created_at_time]
    params[:post][:user_id] = current_user.id
    @post = @current_shard.posts.find(params[:id]) || not_found

    validated=true
    if params[:post][:contents_attributes]
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

    @form_legend = t("author.post.form_legend.edit")

    respond_to do |format|
      if validated &&  @post.update_attributes(params[:post])
        job = Delayed::Job.find_by_id(@post.job_id)
        job.destroy if job
        if @post.publish_at && @post.publish_at > Time.now
          ap @post.workflow_state
          @post.delay! unless (@post.delayed? || @post.published?)
          ap @post.workflow_state
          job = Delayed::Job.enqueue(PublishingJob.new(@current_shard, @post), run_at: @post.publish_at) unless Rails.env.test?
          @post.update_attribute(:job_id, job.id)
        else
          @post.draft! unless @post.published?
          @post.update_attribute(:job_id, nil)
        end
        format.html { redirect_to (@post.stream_name == :personal ? blog_posts_path : news_posts_path), notice: 'Post was successfully updated.' }
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
      format.html { redirect_to (stream == :personal ? blog_posts_path : news_posts_path), notice: 'Post was successfully deleted.' }
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
          flash[:error_notice]=e.terminal.to_s+" : "+t("author.post.reconnect_terminal_error")
        else
          flash[:error_notice]=e.terminal.to_s+" : "+e.user_note
        end

        flash[:error_notice_ext]=e.terminal.to_s+" >>> "+t("author.post.reconnect_terminal_error") + " (#{e}: #{e.parent})"
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
    # redirect_to posts_path, notice: "Post was succesfully #{'un' unless @post.sticky}sticked."
    render nothing: true
  end
  
  def statistics
    @post = @current_shard.posts.find(params[:post_id]) || not_found
  end
  
  def statistics_update
    @post = @current_shard.posts.find(params[:post_id]) || not_found
    @post.contents.each do |content|
      content.social_contents.each do |social_content|
        social_content.update_post_counts if social_content.published?
      end
    end
    redirect_to :back
  end

private

  def assets
    @albums = @current_shard.albums
    @videos = @current_shard.videos.default_order
  end

  def post_params
    params.permit(post: %w[
      stream publish_at created_at publish_at contents_attributes
    ].map(&:to_sym))
  end
  
  def set_section_class
    @section_class = "posts"
  end
  
  def publication_patterns
    @patterns = @current_shard.publication_patterns
  end
end
end
