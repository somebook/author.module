Rails.application.routes.draw do

  mount AuthorModule::Engine => "/author.module"
end
