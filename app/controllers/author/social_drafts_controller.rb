class Author::SocialDraftsController < Author::SpaceController
  def index
    @social_drafts = @current_shard.social_drafts.where(deleted: false).order("created_at DESC")
  end
  
  def import
    draft = SocialDraft.find_by_id_and_shard_id(params[:id], @current_shard.id)
    draft.import(params[:stream])
    redirect_to author_social_drafts_path, notice: "Succesfully imported."
  end
  
  def destroy
    draft = SocialDraft.find_by_id_and_shard_id(params[:id], @current_shard.id)
    draft.deleted = true # destroyed reserved by ActiveRecord
    draft.save
    redirect_to author_social_drafts_path, notice: "Succesfully destroyed."
  end
end