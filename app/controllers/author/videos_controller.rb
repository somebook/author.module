require "aws/s3"

module Author
class VideosController < SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]
  before_filter :check_connects

  def index
    @videos = @current_shard.videos.default_order
  end

  def new
    # youtube = Somebook::Application.config.social_app_accounts[@current_shard.name.to_sym][:youtube]
    @video = Video.new(
      stream: params[:stream] || params[:video][:stream],
      categories: [:people],
      shard: @current_shard,
      amazon: @amazon,
      youtube: @youtube
    )
    @form_legend = t("author.video.form_legend.new")

    render :form
  end

  def edit
    @video = @current_shard.videos.find(params[:id]) || not_found
    @form_legend = t("author.video.form_legend.edit")

    render :form
  end

  def upload
    @video = @current_shard.videos.find(params[:id])
    @upload_info = @video.youtube_client.upload_token(@video.upload_params, uploaded_video_url(@video))
    if @video.amazon
      @key = Somebook::Application.config.social_app_accounts[:amazon][:access_key_id]
      @policy = s3_upload_policy_document
      @signature = s3_upload_signature
    end
  end

  def uploaded
    @video = @current_shard.videos.find(params[:id])
    formats = %w[ .mp4 .m4v .avi .mpeg4 .webm .jpg ]
    if params[:key] && !formats.include?(params[:key].gsub(/^.*(\.[^\.]+)$/,'\\1'))
      flash[:notice] = t("author.video.notice.bad_format", good_formats: formats.join(", "))
      return render :upload
    end

    file = params[:key]
    @video.update_attributes(filename: file, youtube_id: request.query_parameters[:id])

    if @video.youtube && @video.amazon
      video = @video.youtube_client.video_upload(RestClient.get(@video.url(false)),
        title: @video.title,
        description: @video.desc
      )
      @video.update_attributes(
        youtube_id: video.video_id.match(/video:(.*)/)[1],
        youtube: true
      )
    elsif @video.youtube
      @video.fill_info_from_youtube
    end

    @video.encode if @video.amazon

    redirect_to videos_path, notice: t("author.video.notice.upload_success")
  end

  def create
    @video = Video.new(params[:video])
    @video.user = current_user
    @video.shard = @current_shard
    @form_legend = t("author.video.form_legend.new")
    @video.stream = params[:stream] || params[:video][:stream]
    params[:video][:categories] = [params[:video][:categories].to_sym] unless params[:video][:categories].nil?

    if @video.errors.empty? && @video.save
      redirect_to upload_video_path(@video)
    else
      render :form
    end
  end

  def update
    @video = @current_shard.videos.find(params[:id]) || not_found
    params[:video][:user_id] = current_user.id
    params[:video][:categories] = [params[:video][:categories].to_sym] unless params[:video][:categories].nil?

    @form_legend = t("author.video.form_legend.edit")

    if @video.update_attributes(params[:video])
      if @video.youtube_id?
        redirect_to videos_path, notice: t("author.video.notice.update_success")
      else
        redirect_to upload_video_path(@video)
      end
    else
      render :form
    end
  end

  def destroy
    @video = @current_shard.videos.find(params[:id]) || not_found
    @video.destroy

    redirect_to videos_path, notice: t("author.video.notice.delete_success")
  end

  def syncronize
    # Temporary hack to fix tests.
    # TODO: Cover it with RSpec.
    Delayed::Job.enqueue(VideoSyncronizeJob.new(@current_shard), { priority: 10 }) unless Rails.env.test?

    redirect_to videos_path, notice: t("author.video.notice.sync_queued")
  end

private

  # Generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    @policy ||= Base64.encode64({
      "expiration" => 5.minutes.from_now.utc.xmlschema,
      "conditions" => [
        { "bucket" => @current_shard.amazon_setting.video_bucket },
        { "acl" => "public-read" },
        [ "starts-with", "$key", "videos/" ],
        { "redirect" => uploaded_video_url(@video) },
        { "success_action_status" => "200" },
        [ "content-length-range", 0, 2.gigabytes ]
      ]
    }.to_json).gsub(/\n/,'').gsub(/\r/,'')
  end

  # Sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    Base64.encode64(OpenSSL::HMAC.digest(
      OpenSSL::Digest::Digest.new('sha1'),
      @current_shard.amazon_setting.secret_access_key,
      s3_upload_policy_document)
    ).gsub(/\n|\r/, "")
  end
  
  def check_connects
    @amazon = @current_shard.amazon_setting && !@current_shard.amazon_setting.video_bucket.empty?
    @youtube = !Account.find_by_shard_id_and_provider(@current_shard.id, :youtube).nil?
  end
  
  def set_section_class
    @section_class = "videos"
  end

end
end
