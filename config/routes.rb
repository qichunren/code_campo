CodeCampo::Application.routes.draw do
  root :to => 'homepage#index'

  get 'signup' => 'users#new', :as => :signup
  get 'login' => 'user_sessions#new', :as => :login
  delete 'logout' => 'user_sessions#destroy', :as => :logout
  resources :users, :only => [:create]
  resources :user_sessions, :only => [:create]

  get '~:name', :controller => 'people', :action => 'show', :as => :person
  resources :resources, :only => [:index, :show, :new, :create] do
    collection do
      get 'tagged/:tag', :action => 'tagged', :as => :tagged, :constraints  => { :tag => /[^\/]+/ }, :format => false
      get :voted
      get :my
      get :interesting
    end
    member do
      put :vote_up
      delete :vote_up, :action => :unvote_up
    end
  end
  resources :comments, :only => [:new, :create] do
    member do
      put :vote_up
      delete :vote_up, :action => :unvote_up
    end
  end
  resources :topics, :only => [:index, :show, :new, :create, :edit, :update] do
    collection do
      get :my
      get :marked
      get :replied
      get 'tagged/:tag', :action => 'tagged', :as => :tagged, :constraints  => { :tag => /[^\/]+/ }, :format => false
      get :interesting
    end
    member do
      post :mark
      delete :mark, :action => 'unmark'
    end
  end
  resources :replies, :only => [:new, :create, :edit, :update]
  namespace :settings do
    resource :account, :only => [:show, :update]
    resource :password, :only => [:show, :update]
    resource :profile, :only => [:show, :update]
    resources :favorite_tags, :only => [:index, :create, :update, :destroy]
  end
end
