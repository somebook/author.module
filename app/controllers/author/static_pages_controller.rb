class Author::StaticPagesController < Author::SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, :except => [:publish,:destroy,:show]
  before_filter :assets, only: [:new, :edit]

  def index
    @static_pages = @current_shard.static_pages
  end

  def show
  end

  def new
    @static_page = StaticPage.new
    @shard_languages.each{ |c| @static_page.contents << Content.new(shard_language_id: c.id, is_enabled: true)}
    @form_legend = t('author.static_page.form_legend.new')
    render :form
  end

  def create
    params[:static_page][:contents_attributes].each do |k,ca|
      ca[:is_enabled]=ca[:is_enabled] ? true : false
    end
    @static_page = StaticPage.new(static_page_params[:static_page])
    @static_page.shard=@current_shard
    @static_page.user=current_user

    if @static_page.save
      redirect_to author_static_pages_path, notice: 'Static page was successfully created.'
    else
      redirect_to new_author_static_page_path, error: 'Page creation fails.'
    end
  end
  
  def destroy
    @static_page = StaticPage.find_by_id(params[:id])
    if @static_page.destroy
      redirect_to author_static_pages_path, notice: 'Static page was successfully deleted.'
    else
      redirect_to author_static_pages_path, error: 'There were errors while deleting static page.'
    end
  end
  
  def edit
    @static_page = StaticPage.find_by_id(params[:id])
    @form_legend = t('author.static_page.form_legend.edit')
    render :form
  end
  
  def update
    params[:static_page][:contents_attributes].each do |k,ca|
      ca[:is_enabled]=ca[:is_enabled] ? true : false
    end
    @static_page = StaticPage.find_by_id(params[:id])
    if @static_page.update_attributes( static_page_params[:static_page])
      redirect_to author_static_pages_path, notice: 'Page was successfully updated.'
    else
      redirect_to edit_author_static_pages_path(@album), error: 'There were errors while updating static page'
    end
  end

  private 

  def shard_languages
    @shard_languages = @current_shard.shard_languages
  end
  
  def assets
    @albums = @current_shard.albums
    @videos = @current_shard.videos.default_order
  end
  def static_page_params
    p=params.permit(static_page: [
                    :position, :created_at, :permalink, :layout, :section, :contents_attributes, :page_class])
    p
  end

end
