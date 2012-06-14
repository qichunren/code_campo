class PeopleController < ApplicationController
  before_filter :find_person

  def show
    @topics = @person.topics.order_by([[:created_at, :desc]]).page(1).per(10)
    @topics_count = @person.topics.count
    @replies_count = @person.replies.count
    @repos_count = @person.public_repos_count
    @followers_count = @person.github_followers_count

    @person.sync_at = nil

    key = @person.name.to_s + "_33sync"
    #if cookies[key.to_sym].nil?
      cookies[key.to_sym] = { :value => "true", :expires => 1.hours.from_now }
      @person.async_sync! if @person.present?
    #end

  end

  protected

  def find_person
    @person = GUser.first :conditions => {:name => /^#{params[:name]}$/i}
    raise Mongoid::Errors::DocumentNotFound.new(User, params[:name]) if @person.nil?
  end
end
