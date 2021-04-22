class CommentsController < ApplicationController
  skip_before_action :authorize!, only: [:index]
  before_action :load_article
  include Paginable

  # GET /comments
  def index
    paginated = paginate(@article.comments)
    render_collection(paginated)
  end

  # POST /comments
  def create
    @comment = @article.comments.build(
      comment_params.merge(user: current_user)
    )
    @comment.save!
    render json: serializer.new(@comment), status: :created
  rescue
    raise Errors::Invalid.new({ errors: @comment.errors.to_hash })
  end

  def serializer
    CommentSerializer
  end

  private

  def load_article
    @article = Article.find(params[:article_id])
  end
  
  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:data).require(:attributes).
      permit(:content) ||
    ActionController::Parameters.new
  end
end
