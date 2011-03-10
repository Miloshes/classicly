class SearchController < ApplicationController

  def show
    @search = params[:term]
    @books = Book.joins(:collections).joins(:author).where(
      {:title.matches => "%#{@search}%"} | 
      {:collections => {:name.matches => "%#{@search}%"}} |
      {:author => {:name.matches => "%#{@search}%"}}).page(params[:page]).per(10)
  end

end
