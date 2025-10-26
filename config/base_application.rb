require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/reloader' if development?

class BaseApplication < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Reloader if development?

  configure do
    set :database, { adapter: 'sqlite3', database: 'db/development.sqlite3' }
    set :views, 'app/presentation/views'
    set :public_folder, 'app/presentation/public'
    enable :method_override  # POSTリクエストで_methodパラメータを使用してDELETEメソッドをエミュレート
  end

  configure :development do
    register Sinatra::Reloader
  end
end

