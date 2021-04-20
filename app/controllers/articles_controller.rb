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
    if article.valid?
      #
    else
      raise Errors::Invalid.new({ errors: article.errors.to_hash })
    end
  end

  def serializer
    ArticleSerializer
  end

  private

  def article_params
    ActionController::Parameters.new
  end
end
