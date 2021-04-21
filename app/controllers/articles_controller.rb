class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]
  include Paginable
  
  def index
    paginated = paginate(Article.recent)
    render_collection(paginated)
  end

  def show
    article = Article.find(params[:id])
    render json: serializer.new(article)
  end

  def create
    article = Article.new(article_params)
    article.save!
    render json: serializer.new(article), status: :created
  rescue
    raise Errors::Invalid.new({ errors: article.errors.to_hash })
  end

  def update
    article = Article.find(params[:id])
    article.update!(article_params)
    render json: serializer.new(article)
  rescue
    raise Errors::Invalid.new({ errors: article.errors.to_hash })
  end

  def serializer
    ArticleSerializer
  end

  private

  def article_params
    params.require(:data).require(:attributes).
      permit(:title, :content, :slug) ||
    ActionController::Parameters.new
  end
end
