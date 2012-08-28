module Author
  module Settings
    class ShardUsersController < ::Author::SpaceController
      load_and_authorize_resource class: "Assignment"

      def add
        if user = User.find_by_email(params[:user_email]) and (im_author? || im_master?)
          user.assignments.create(
            role_id: Role.find_by_name('author').id,
            shard_id: @current_shard.id
          )
        end

        redirect_to settings_path, notice: t("author.shard_user.notice.create_success")
      end

      def revoke
        assignment = @current_shard.assignments.for_role(:author).find(params[:id]) || not_found
        assignment.destroy

        redirect_to settings_path, notice: t("author.shard_user.notice.delete_success")
      end

    end
  end
end