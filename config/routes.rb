Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :group_events, only: [:index, :create, :update, :show, :destroy] do
        post :publish, on: :member
        post :recover, on: :member
      end
    end
  end
end
