require File.join(File.dirname(__FILE__), 'test_helper')
require 'test/unit'

class Array
  def chunks(length)
    a = []
    each_with_index do |e, i|
      a << [] if i % length == 0
      a.last << e
    end
    a
  end
end

ActionController::Routing::Routes.draw do |map|
  map.resources :articles, :path_prefix => ":locale"
  map.resources :features, :path_prefix => ":locale"
end

class StubController < ActionController::Base
  attr_accessor :request, :url, :locale
  def rescue_action(e) raise e end;
end

class LocalizedUrlHelperTest < Test::Unit::TestCase
  attr :params
  
  def setup
    @params = {:locale => 'en', :controller => "articles", :action => :show, :id => "1"}
    @request = ActionController::TestRequest.new
    @request.path_parameters = params
    @response = ActionController::TestResponse.new
    @controller = StubController.new
    @controller.locale = params[:locale]
    @controller.url = ActionController::UrlRewriter.new @request, params
  end
  
  def test_same_collection_path
    assert_equal "/en/articles", @controller.articles_path
  end
  
  def test_foreign_collection_path
    assert_equal "/en/features", @controller.features_path
  end
  
  def self.define_tests(name)
    tests = [ :nothing,               "/en/#{name}s/1", [ ],
              :positioned_same_id,    "/en/#{name}s/1", [ 1 ],
              :positioned_other_id,   "/en/#{name}s/9", [ 9 ],
              :named_id,              "/en/#{name}s/9", [ :id => 9 ],
              :named_locale,          "/fr/#{name}s/1", [ :locale => 'fr' ],
              :named_locale_and_id,   "/fr/#{name}s/9", [ :locale => 'fr', :id => 9 ] ]
    tests.chunks(3).each do |param_name, expected, path_args|
      define_method("test_#{name}_path_with_#{param_name}".to_sym) do 
        assert_equal expected, @controller.method("#{name}_path").call(*path_args) 
      end
    end
  end
  
  self.define_tests(:article)
  self.define_tests(:feature)
end
