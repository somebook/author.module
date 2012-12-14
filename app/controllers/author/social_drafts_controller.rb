module Author
class SocialDraftsController < SpaceController

  def index
    @social_drafts = @current_shard.social_drafts.where(deleted: false).order("created_at DESC").paginate(page: params[:page], per_page: 20)
    ap @social_drafts
  end

  def import
    draft = SocialDraft.find_by_id_and_shard_id(params[:id], @current_shard.id)
    draft.import(params[:stream])
    redirect_to social_drafts_path, notice: t("author.social_draft.notice.import_success")
  end

  def destroy
    draft = SocialDraft.find_by_id_and_shard_id(params[:id], @current_shard.id)
    draft.update_attributes(deleted: true)

    redirect_to social_drafts_path, notice: t("author.social_draft.notice.delete_success")
  end
  
  private
  
  def set_section_class
    @section_class = "social_drafts"
  end

end
end
