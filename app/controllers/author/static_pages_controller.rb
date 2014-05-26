module Author
class StaticPagesController < SpaceController
  load_and_authorize_resource
  before_filter :shard_languages, except: [:publish, :destroy, :show]
  before_filter :assets, only: [:new, :edit]

  def index
    @static_pages = @current_shard.static_pages
  end

  def new
    @static_page = StaticPage.new(
      contents: @shard_languages.map{ |shard_language|
        Content.new(shard_language_id: shard_language.id, is_enabled: true)
      }
    )
    @form_legend = t("author.static_page.form_legend.new")

    render :form
  end

  def create
    params[:static_page][:contents_attributes].each do |key, contents_attribute|
      contents_attribute[:is_enabled] = !!contents_attribute[:is_enabled]
    end
    @static_page = StaticPage.new(static_page_params[:static_page])
    @static_page.shard = @current_shard
    @static_page.user = current_user

    if @static_page.save
      redirect_to static_pages_path, notice: t("author.static_page.notice.create_success")
    else
      render :form
    end
  end

  def destroy
    @static_page = StaticPage.find_by_id(params[:id]) || not_found

    if @static_page.destroy
      redirect_to static_pages_path, notice: t("author.static_page.notice.delete_success")
    else
      redirect_to static_pages_path, error: t("author.static_page.notice.delete_fail")
    end
  end

  def edit
    @static_page = StaticPage.find_by_id(params[:id]) || not_found
    @form_legend = t("author.static_page.form_legend.edit")

    render :form
  end

  def update
    params[:static_page][:contents_attributes].each do |key, contents_attribute|
      contents_attribute[:is_enabled] = !!contents_attribute[:is_enabled]
    end
    @static_page = StaticPage.find_by_id(params[:id])
    @form_legend = t("author.static_page.form_legend.edit")

    if @static_page.update_attributes(params[:static_page])
      redirect_to static_pages_path, notice: t("author.static_page.notice.update_success")
    else
      render :form
    end
  end

private

  def assets
    @albums = @current_shard.albums
    @videos = @current_shard.videos.default_order
  end

  def static_page_params
    params.permit(static_page: %w[
      position created_at permalink layout section contents_attributes page_class
    ].map(&:to_sym))
  end
  
  def set_section_class
    @section_class = "static_pages"
  end

end
end
