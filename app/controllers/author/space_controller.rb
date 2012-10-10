module Author
class SpaceController < ::ApplicationController
  force_ssl if Rails.env.production?
  layout "author"
  before_filter :authenticate_user!, :set_shard, :authenticate_author!, :set_section_class,
                :check_pending_social_contents, :set_accessible_shards

  def set_my_shard
    shard = Shard.find(params[:shard_id])
    if im_author?(shard) or im_master?(shard)
      cookies[:current_shard_id] = shard.id
    end

    redirect_to root_path
  end

private

  def shard_languages
    @shard_languages ||= @current_shard.shard_languages
  end

  def authenticate_author!
    raise unless user_signed_in?
    raise unless @current_shard

    raise unless im_author? or im_master?
  rescue
    redirect_to "/users/login/"
  end

  def set_shard
    @current_shard = catch(:cookie_shard) do
      if cookies[:current_shard_id]
        if shard = Shard.find(cookies[:current_shard_id])
          if im_author?(shard) or im_master?(shard)
            throw :cookie_shard, shard
          end
        end
      end

      if shard = current_user.all_shards_for_roles([:master, :author])
        throw :cookie_shard, shard[0]
      end

      if current_user.has_role?(:admin)
        throw :cookie_shard, Shard.first
      end

      nil
    end
  end

  def im_author?(shard = nil)
    shard ||= @current_shard
    current_user.has_role_for_shard?(:author, shard)
  end

  def im_master?(shard = nil)
    shard ||= @current_shard
    current_user.has_role_for_shard?(:master, shard)
  end

  def check_pending_social_contents
    if im_master?
      @pending_social_contents = @current_shard.social_contents.with_status(:pending)
    end
  end

  def set_accessible_shards
    @accessible_shards = current_user.all_shards_for_roles([:author, :master])
  end
  
  def set_section_class    
  end

end
end
