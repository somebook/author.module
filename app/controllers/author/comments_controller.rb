module Author
class CommentsController < SpaceController
  before_filter {
    require "commentatr"
    # Local Commentatr hack
    # ::Commentatr::Request.const_set("HOST", "dev.commentatr.net")
    # ::Commentatr::Request.const_set("PORT", 3001)

    if params[:post_id] and params[:content_id]
      @post = Post.find(params[:post_id])
      @content = Content.find(params[:content_id])
      @shard_language = @content.shard_language
      @commentatr_token_set = @shard_language.commentatr_token.present?
      @commentatr = Commentatr::Client.new(
        partner_host: @shard_language.domain,
        token: @shard_language.commentatr_token,
        page_id: @content.commentatr_hash
      )
    else
      @commentatr = Commentatr::Client.new(
        client_id: 1,
        token: "0d4c8c1a10c54bb8d4d93cf2b422e4e90408b325"
      )
    end
  }

  def index

  end

  def blog
    get_comments(:comments, 0)
  end

  def client
    get_comments(:client_comments, 200)
  end

  %w[ delete approve reject junk ].each { |action|
    define_method(action) do
      modify_comment(action.to_sym)
    end
  }

private

  def get_comments(action, limit)
    response = @commentatr.send(action, { order: "desc", limit: limit })

    unless response.body.nil? or response.code != 200
      @comments = response.body.data
    else
      @comments = []
      @commentatr_unavailable = true
    end

    respond_to do |format|
      format.html
      format.json { render json: @comments }
    end
  end

  def modify_comment(action)
    response = @commentatr.send(action, { comment_id: params[:id] })

    respond_to do |format|
      format.html {
        redirect_to(post_content_comments_path(params[:post_id], params[:content_id]),
        response.body && response.code == 200 && response.body.success == true ?
          { notice: translate("author.comments.notice.#{action}.success") } :
          { flash: { error: translate("author.comments.notice.#{action}.failed") } }
        )
      }
      format.json {
        head response["success"] == true ? :accepted : :bad_request
      }
    end
  end

end
end
