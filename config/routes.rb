Rails.application.routes.draw do

  mount Attachinary::Engine => "/attachinary"

  get '/amp', to: 'website#amp'
  post '/contactme', to: 'website#contactme'
  get '/faq', to: 'faq#show'

  resources :mfiles
  patch 'messages/add_photo/:id', to: 'messages#add_photo', as: 'messages_add_photo'
  patch 'messages/update_formdata/:id', to: 'messages#update_formdata', as: 'messages_update_form'
  get 'm/:uuid', to: 'messages#show', as: "message_form"
  resources :messages
  patch '/messages/update_groups/:id', to: 'messages#update_groups'
  patch '/messages/publish/:id', to: 'messages#publish', as: 'publish_message'
  patch '/messages/unpublish/:id', to: 'messages#unpublish', as: 'unpublish_message'
  patch '/messages/send_for_approval/:id', to: 'messages#send_for_approval', as: 'send_for_approval_message'
  patch '/messages/accept/:id', to: 'messages#accept', as: 'accept_message'
  patch '/messages/reject/:id', to: 'messages#reject', as: 'reject_message'

  resources :groups
  patch '/groups/update_students/:id', to: 'groups#update_students'
  get '/students/import_csv_student', to: 'students#new_import_csv', as: 'new_import_csv'
  post '/students/export_csv', to: 'students#export_csv'
  post '/students/csv_upload', to: 'students#csv_upload'
  delete '/students/destroy_all', to: 'students#destroy_all'
  resources :students
  patch '/students/update_groups/:id', to: 'students#update_groups'
  devise_for :users, :controllers => { :invitations => 'invitations' }
  get 'schools/edit_current', to: 'schools#edit', as: 'edit_current_school'
  resources :schools
  post 'schools/add_logo', to: 'schools#add_logo'
  post 'schools/change_school', to: 'schools#change_school'
  get 'users/resend_invite/:id', to: 'users#resend_invite', as: 'resend_invite'

  resources :users
  patch '/users/update_schools/:id', to: 'users#update_schools'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  authenticated :user do
    root 'messages#index', as: :authenticated_root
  end

  devise_scope :user do
    root to: 'website#index'
  end
end
