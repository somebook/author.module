require 'aws/s3'

class Author::VideosController < Author::SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]

  # GET /videos
  # GET /videos.json
  def index
    @videos = @current_shard.videos.default_order
    respond_to { |format|
      format.html # index.html.erb
      format.json { render json: @videos }
    }
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    @video = @current_shard.videos.find(params[:id])

    respond_to { |format|
      format.html # show.html.erb
      format.json { render json: @video }
    }
  end

  # GET /videos/new
  # GET /videos/new.json
  def new
    @video = Video.new
    @form_legend = t("author.video.form_legend.new")
    @video.stream = params[:stream] || params[:video][:stream]
    @video.categories = [:people]
    @video.shard = @current_shard
    @video.youtube = true if Somebook::Application.config.social_app_accounts[@current_shard.name.to_sym][:youtube][:username] && Somebook::Application.config.social_app_accounts[@current_shard.name.to_sym][:youtube][:password]
    ap Somebook::Application.config.social_app_accounts[@current_shard.name.to_sym][:youtube][:username] && Somebook::Application.config.social_app_accounts[@current_shard.name.to_sym][:youtube][:password]

    respond_to { |format|
      format.html { render :form }
      format.json { render json: @video }
    }
  end

  # GET /videos/1/edit
  def edit
    @video = @current_shard.videos.find(params[:id]) || not_found
    @form_legend = t("author.video.form_legend.edit")
    respond_to { |format|
      format.html { render :form }
    }
  end

  def upload
    @video = @current_shard.videos.find(params[:id])
    @key = Somebook::Application.config.social_app_accounts[:amazon][:access_key_id]
    @policy = s3_upload_policy_document
    @signature = s3_upload_signature
  end

  def uploaded
    @video=@current_shard.videos.find(params[:id])
    ff=[".mp4", ".m4v", ".avi", ".mpeg4", ".webm", ".jpg"]
    if params[:key]
      unless ff.include? params[:key].gsub(/^.*(\.[^\.]+)$/,'\\1')
        render text: "wrong file format! #{ff.join(',')} accepted "
        return
      end
    end

    file = params[:key]
    @video.update_attribute(:filename, "#{file}")
    if @video.youtube
      v = @video.client.video_upload(@video.url(false), title: @video.title, description: @video.desc)
      @video.update_attribute(:youtube_id, v.video_id.match(/video:(.*)/)[1])
      @video.update_attribute(:youtube, true)
    end
    @video.encode
    redirect_to author_videos_path, notice: 'Video was successfully uploaded.'
  end
  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(params[:video])
    @video.user = current_user
    @video.shard = @current_shard
    @form_legend = t("author.video.form_legend.new")
    @video.stream = params[:stream] || params[:video][:stream]
    params[:video][:categories] = [params[:video][:categories].to_sym] unless params[:video][:categories].nil?

    respond_to { |format|
      if @video.errors.empty? && @video.save
        format.html {
          redirect_to upload_author_video_path(@video)
        }
        format.json { render json: @video, status: :created, location: @video }
      else
        format.html { render :form }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    }
  end

  # PUT /videos/1
  # PUT /videos/1.json
  def update
    params[:video][:user_id] = current_user.id
    @video = @current_shard.videos.find(params[:id]) || not_found
    @form_legend = t("author.video.form_legend.edit")
    params[:video][:categories] = [params[:video][:categories].to_sym] unless params[:video][:categories].nil?

    respond_to { |format|
      if @video.update_attributes(params[:video])
        format.html {
          if @video.youtube_id?
            redirect_to author_videos_path, notice: 'Video was successfully updated.'
          else
            redirect_to upload_author_video_path(@video)
          end
        }
        format.json { head :ok }
      else
        format.html { render :form }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    }
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video = @current_shard.videos.find(params[:id]) || not_found
    @video.destroy

    respond_to { |format|
      format.html { redirect_to author_videos_path, notice: 'Video was successfully deleted.' }
      format.json { head :ok }
    }
  end

  # GET /videos/syncronize
  def syncronize
    # Temporary hack to fix tests.
    # TODO: Cover it with RSpec.
    Delayed::Job.enqueue(VideoSyncronizeJob.new(@current_shard), { priority: 10 }) unless Rails.env.test?

    redirect_to author_videos_path, notice: 'Video syncronization queued.'
  end

private

  def shard_languages
    @shard_languages = @current_shard.shard_languages
  end

  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    return @policy if @policy
    ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
      "conditions" =>  [
        {"bucket" =>  Somebook::Application.config.social_app_accounts[@current_shard.name.to_sym][:amazon][:videos_bucket]},
        {"acl" => "public-read"},
        ["starts-with", "$key", "videos/"],
        {"redirect" => uploaded_author_video_url(@video)},
        {"success_action_status" => "200"},
        ["content-length-range", 0, 2.gigabytes]
      ]
    }
    @policy = Base64.encode64(ret.to_json).gsub(/\n/,'').gsub(/\r/,'')
  end

  # sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),
                                Somebook::Application.config.social_app_accounts[:amazon][:secret_access_key],
                                s3_upload_policy_document)).gsub("\n","").gsub("\r",'')

  end
end
