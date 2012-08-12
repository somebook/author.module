class Author::ShardLanguagesController < Author::SpaceController
  load_and_authorize_resource
  # GET /languages
  # GET /languages.json
  #TODO fix this stuff - it's broken some times
  def index
    @languages = @current_shard.shard_languages#where(user_id: current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @languages }
    end
  end

  # GET /languages/1
  # GET /languages/1.json
  def show
    @language = @current_shard.shard_languages.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @language }
    end
  end

  def link_service
    language=@current_shard.shard_languages.find(params[:shard_language_id])
    stream=params[:stream]
    code=params[:code]
    cookies[:language] = language.id
    cookies[:stream]   = stream
    redirect_to user_omniauth_authorize_path(code.downcase.to_sym)
  end
end
