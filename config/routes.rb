Rails.application.routes.draw do
  resources :messages
  patch '/messages/update_groups/:id', to: 'messages#update_groups'
  patch '/messages/publish/:id', to: 'messages#publish', as: 'publish_message'
  resources :groups
  patch '/groups/update_students/:id', to: 'groups#update_students'
  resources :students
  patch '/students/update_groups/:id', to: 'students#update_groups'
  devise_for :users, :controllers => { :invitations => 'invitations' }
  resources :schools
  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  root 'application#welcome'
end
