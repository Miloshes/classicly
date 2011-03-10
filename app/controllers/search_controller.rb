class SearchController < ApplicationController

  def show
    @search = params[:term]
    @books = Book.joins(:collections).where({:title.matches => "%#{@search}%"} | {:collections => {:name.matches => "%#{@search}%"}}).page(params[:page]).per(10)
  end

end
