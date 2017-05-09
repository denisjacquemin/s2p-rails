Rails.application.routes.draw do

  mount Attachinary::Engine => "/attachinary"

  get 'messages/noalgolia_index', to: 'messages#noalgolia_index'

  get '/amp', to: 'website#amp'
  post '/contactme', to: 'website#contactme'
  get '/faq', to: 'faq#show'
  get 'contact_support', to: 'faq#contact_support'
  post '/submit_support', to: 'faq#submit_support'

  get '/help', to: 'faq#outil_pour_lecole'
  get '/guide-d-installation', to: 'website#install_app'

  get 'help/creation_des_eleves', to: 'faq#creation_des_eleves'
  get 'help/creation_des_groupes_de_diffusions', to: 'faq#creation_des_groupes_de_diffusions'
  get 'help/creation_des_redacteurs', to: 'faq#creation_des_redacteurs'
  get 'help/communiquer_les_codes_aux_parents', to: 'faq#communiquer_les_codes_aux_parents'
  get 'help/version_minimale_android', to: 'faq#version_minimale_android'
  get 'help/version_minimale_ios', to: 'faq#version_minimale_ios'
  get 'help/version_android', to: 'faq#version_android'
  get 'help/comment_demarrer', to: 'faq#comment_demarrer'
  get 'help/outil_pour_lecole', to: 'faq#outil_pour_lecole'
  get 'help/outil_pour_les_parents', to: 'faq#outil_pour_les_parents'
  get 'help/approbation_message', to: 'faq#approbation_message'
  get 'help/codes_dacces', to: 'faq#codes_dacces'
  get 'help/notifications', to: 'faq#notifications'
  get 'help/formulaire', to: 'faq#formulaire'
  get 'help/excelunecolonne', to: 'faq#excelunecolonne'



  resources :mfiles
  get 'messages/exportform', to: 'messages#export_formdata', as: 'export_formdata'
  patch 'messages/add_photo/:id', to: 'messages#add_photo', as: 'messages_add_photo'
  patch 'messages/update_formdata/:id', to: 'messages#update_formdata', as: 'messages_update_form'
  get 'm/:uuid', to: 'messages#show', as: "message_form"
  post 'm/save_form', to: 'messages#save_form'
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
