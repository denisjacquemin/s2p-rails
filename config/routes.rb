Rails.application.routes.draw do
  resources :students
  devise_for :users, :controllers => { :invitations => 'invitations' }
  resources :schools
  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  root 'application#welcome'
end
