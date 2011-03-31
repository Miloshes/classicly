class BingoExperimentsController < ApplicationController
  def create
    bingo! 'facebook_like_dowload'
    render :text => ''
  end
end
