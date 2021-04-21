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

    if @comment.save
      render json: @comment, status: :created, location: @article
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
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
    params.require(:comment).permit(:content)
  end
end
