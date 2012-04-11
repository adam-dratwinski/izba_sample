#encoding: UTF-8
Izba::Application.routes.draw do

  match 'signup' => 'users#new', :as => :signup, :path => "rejestracja"
  match 'logout' => 'sessions#destroy', :as => :logout, :path => "wyloguj"
  match 'login' => 'sessions#new', :as => :login, :path => "zaloguj"


  resources :page_parts, :only => [:show], :path => "strony"

  resource :geocodes do
    post :find
  end

  resources :search_clinics, :only => :create

  scope :only => [:index, :show] do
    resources :departaments, :path => "instytucje" do
      resources :verifications, :only => [:new, :create]
      resources :data_reports, :only => [:new, :create]
    end
    resources :diseases
    resources :diseases_letters
    resources :specialisations 
    resources :specialisations_letters
    resources :offices, :path => "oddzialy"
    resources :clinics do
      get :search, :on => :member, :path => "szukaj", :action => :index
      get :window, :on => :member
      resources :data_reports, :only => [:new, :create]
    end
    resources :clinics_tags
    resources :states, :path => "wojewodztwa" do
      get :clinics, :on => :collection, :controller => :clinics, :action => :index, :path => "placowki"
      resources :clinics, :path => "placowki" do
        get :search, :on => :member, :path => "szukaj", :action => :index
      end
    end
    resources :cities, :path => "miasta" do
      resources :clinics, :path => "placowki" do
        get :search, :on => :member, :path => "szukaj", :action => :index
      end
    end
    match '/:id/placowki' => "clinics#show", :id => /[\w0-9-]+/, :as => :clinic
    match '/:id/instytucje' => "departaments#show", :id => /[\w0-9-]+/, :as => :departament
    match '/:id/oddzialy' => "offices#show", :id => /[\w0-9-]+/, :as => :office
    resources :clinics, :path => "placowki" do
      get :search, :on => :member, :path => "szukaj", :action => :index
      get :markers, :on => :member
      get :others, :on => :member, :path => "inne"
      resources :inquiries, :only => [:index, :show, :create], :path => "kontakt"
      resources :offices, :path => "oddzialy"
    end
  end

  resources :inquiries, :only => [:create]

  resource :session, :only => [:new, :create, :destroy]
  resource :user, :only => [:new, :create] do
    get :hide_geolocation_notice, :on => :member
    get :set_geolocation, :on => :member
    get :set_city, :on => :member
  end

  match 'profile/my_account' => 'profile/users#edit', :as => :my_account

  namespace :profile do
    root :to => "users#edit"
    resources :clinics
    resources :offices
    resources :data_reports do 
      get :read, :on => :collection
      get :unread, :on => :collection
      put :mark_as_unread, :on => :member
      put :mark_as_read, :on => :member
    end
    resources :inquiries do 
      get :read, :on => :collection
      get :unread, :on => :collection
      put :mark_as_unread, :on => :member
      put :mark_as_read, :on => :member
    end
    resources :specialisations 
    resources :galleries do
      resources :images, :only => [:create, :destroy]
    end
    resources :pages 
    resources :page_parts 
    resources :diseases 
    resources :departaments do
      get :crop_logo, :on => :member
      resources :offices
      resources :clinics
      resources :users, :controller => "departament_users"
    end
    resources :users do
      resource :departament, :controller => "user_departament", :only => [:show, :edit, :update]
      collection do 
        get 'recent'
        get 'unverified'
      end
      get :change_password, :on => :member
      put :verify, :on => :member
      put :unverify, :on => :member
    end
  end

  root :to => "main#index"
end
