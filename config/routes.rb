Rails.application.routes.draw do
  resources :mfiles
  resources :messages
  patch '/messages/update_groups/:id', to: 'messages#update_groups'
  patch '/messages/publish/:id', to: 'messages#publish', as: 'publish_message'
  patch '/messages/unpublish/:id', to: 'messages#unpublish', as: 'unpublish_message'
  patch '/messages/send_for_approval/:id', to: 'messages#send_for_approval', as: 'send_for_approval_message'
  patch '/messages/accept/:id', to: 'messages#accept', as: 'accept_message'
  patch '/messages/reject/:id', to: 'messages#reject', as: 'reject_message'

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
