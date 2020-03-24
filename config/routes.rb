Rails.application.routes.draw do

  authenticated :user, -> user { user.superadmin? } do
    mount Delayed::Web::Engine, at: '/jobs'
  end

  resources :rating_comments
  post 'rating_comments/update_orders', to: 'rating_comments#update_orders'

  resources :rating_years
  post 'periods/update_orders', to: 'periods#update_orders'
  resources :periods
  
  post 'ratings/change_group', to: 'ratings#change_group'
  post 'ratings/change_student', to: 'ratings#change_student'
  post 'ratings/report_to_pdf', to: 'ratings#report_to_pdf'
  get 'ratings/choose_report_period', to: 'ratings#choose_report_period'
  post 'ratings/reports_to_pdf', to: 'ratings#reports_to_pdf'


  get 'ratings/by_student', to: 'ratings#by_student', as: 'by_student'
  post 'ratings/students', to: 'ratings#students', as: 'ratings_students'
  post 'ratings/save', to: 'ratings#save'
  patch 'ratings/save_comment', to: 'ratings#save_comment', as: 'save_comment'
  get 'ratings/edit_comment/:competency_id/:student_id/:period_id', to: 'ratings#edit_comment', as: 'rating_edit_comment'


  resources :ratings

  patch 'users/update_competency_groups/:id', to: 'users#update_competency_groups', as: 'update_competency_groups'
  get 'competencies/writers_access', to: 'competencies#writers_access', as: 'writers_access'
  get 'users/edit_competency_groups/:id', to:'users#edit_competency_groups', as: 'edit_competency_groups'
  resources :competencies
  post 'competencies/update_orders', to: 'competencies#update_orders'

  get '/monitors', to: 'monitors#index'
  resources :message_categories
  get 'webhook/pq_confirm/:pqid', to: 'webhook#pq_confirm'

  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]

  resources :form_templates, :except => :show
  get '/form_templates/loadformtemplate', to: 'form_templates#load_form_template'
  mount Attachinary::Engine => "/attachinary"

  get 'messages/noalgolia_index', to: 'messages#noalgolia_index'
  get 'messages/billed_students_list', to: 'messages#billed_students_list'
  post 'students/recipients', to: 'students#students_recipients'


  get '/amp', to: 'website#amp'
  get '/disclaimer', to: 'website#disclaimer'
  post '/contactme', to: 'website#contactme'
  get '/faq', to: 'faq#show'
  get 'contact_support', to: 'faq#contact_support'
  post '/submit_support', to: 'faq#submit_support'

  get '/help', to: 'faq#accueil'
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
  get 'help/whatsnew', to: 'faq#whatsnew'
  get 'help/import_winpage', to: 'faq#import_winpage'
  get 'help/export_winpage', to: 'faq#export_winpage'
  get 'help/export_gestscol', to: 'faq#export_gestscol'
  get 'help/export_siel', to: 'faq#export_siel'
  get 'help/export_proeco', to: 'faq#export_proeco'
  get 'help/export_creos', to: 'faq#export_creos'
  get 'help/import_excel', to: 'faq#import_excel'
  get 'help/message_sms', to: 'faq#message_sms'
  get 'help/update_students', to: 'faq#update_students'
  get 'help/delete_students', to: 'faq#delete_students'
  get 'help/exportcsv', to: 'faq#exportcsv'
  get 'help/payments', to: 'faq#payments'
  get 'help/payconiq', to: 'faq#payconiq'
  get 'help/form_template', to: 'faq#form_template'
  get 'help/traduction_des_messages', to: 'faq#traduction_des_messages'
  get 'help/bug_android_chrome', to: 'faq#bug_android_chrome'
  get 'help/wetransfer', to: 'faq#wetransfer'
  get 'gts', to: 'faq#gts'



  resources :mfiles
  post '/messages/sendcode', to: 'messages#create_sendcode_message'
  get 'messages/exportform', to: 'messages#export_formdata', as: 'export_formdata'
  get 'messages/refresh_qr/:muuid', to: 'messages#refresh_qr'
  patch 'messages/update_amounttopay/:id', to: 'messages#update_amount_to_pay', as: 'update_amount_to_pay'
  patch 'messages/add_photo/:id', to: 'messages#add_photo', as: 'messages_add_photo'
  patch 'messages/update_formdata/:id', to: 'messages#update_formdata', as: 'messages_update_form'
  get 'm/:uuid/:emailencrypted', to: 'messages#show'
  get 'm/:uuid(:s)', to: 'messages#show', as: "message_form"
  get 'p/:uuid', to: 'messages#show', as: "message_pay"

  post 'm/save_form', to: 'messages#save_form'
  resources :messages
  patch '/messages/update_groups/:id', to: 'messages#update_groups'
  patch '/messages/publish/:id', to: 'messages#publish', as: 'publish_message'
  patch '/messages/unpublish/:id', to: 'messages#unpublish', as: 'unpublish_message'
  patch '/messages/republish/:id', to: 'messages#republish', as: 'republish_message'
  patch '/messages/send_for_approval/:id', to: 'messages#send_for_approval', as: 'send_for_approval_message'
  patch '/messages/accept/:id', to: 'messages#accept', as: 'accept_message'
  patch '/messages/reject/:id', to: 'messages#reject', as: 'reject_message'

  resources :groups
  patch '/groups/update_students/:id', to: 'groups#update_students'
  get '/students/import_csv_student', to: 'students#new_import_csv', as: 'new_import_csv'
  post '/students/export_csv', to: 'students#export_csv'
  post '/students/codes_to_pdf', to: 'students#codes_to_pdf'
  post '/students/csv_upload', to: 'students#csv_upload'
  delete '/students/destroy_all', to: 'students#destroy_all'

  get '/students/new_index', to: 'students#new_index'

  resources :students
  resources :students, :path => "citizens", as: "citizens"
  patch '/students/update_groups/:id', to: 'students#update_groups'
  post '/users/newannouncementsviewed/:count', to: 'users#new_announcements_viewed'
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
  mount ActionCable.server => '/cable'

  authenticated :user do
    root 'messages#index', as: :authenticated_root
  end

  devise_scope :user do
    root to: 'website#index'
  end
end
