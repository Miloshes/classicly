require 'spec_helper'

describe BlogPost do
  
  before :each do
    @author = FactoryGirl.create(:author, :name => 'Kawama San')
    content = "Il y a un lien secret entre la lenteur et la mémoire, entre la vitesse et l’oubli. Evoquons une situation on ne peut
            plus banale : un homme marche dans la rue. Soudain, <featured author_id='#{@author.id}'>il veut se rappeler quelque chose, mais le souvenir lui échappe.</featured>
            A ce moment, machinalement, il ralentit son pas. Par contre, quelqu’un essaie d’oublier un incident pénible qu’il
            vient de vivre accélère à son insu l’allure de sa marche comme s’il voulait vite s’éloigner de ce qui se trouve, 
            dans le temps, encore trop proche de lui."
    @blog_post = FactoryGirl.create(:blog_post, :content => content, :title => 'Kawaii Bo')
  end

  describe '#create_author_quotings' do

    describe 'when creating the quoting for the first time' do
      it 'should create quoting from content between <featured> tags once the blog post is saved' do
        AuthorQuoting.where(:blog_post_id => @blog_post.id).count.should == 1
      end

      it 'should assign a quoted text to the author quoting object' do
        AuthorQuoting.where(:blog_post_id => @blog_post.id).first.quoted_text.should == 'il veut se rappeler quelque chose, mais le souvenir lui échappe.'
      end
    end

    describe 'when updating' do
      it 'should not create duplicates for the author quotings' do
        @blog_post.update_attribute(:title, 'Testing')
        AuthorQuoting.where(:blog_post_id => @blog_post.id).count.should == 1
      end
    end

  end

end
