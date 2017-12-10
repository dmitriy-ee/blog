require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'blog.db'
  @db.results_as_hash = true
end

# before вызывается каждый раз при перезагрузке любой страницы
before do
  # инициализация БД
  init_db
end

# configure вызывается каждый раз раз при конфигурации приложения:
# когда изменился код программы и перезагрузилась страница
configure do

  # инициализация БД
  init_db

  # создает таблицу, если она не существует
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts 
             (
             id INTEGER PRIMARY KEY AUTOINCREMENT, 
             created_date DATE, 
             content TEXT
             )'
end

get '/new' do
  @db.execute 'SELECT * FROM Posts' 
  erb :new
end

post '/new' do

  # получаем переменную из POST запроса
  content = params[:content]

  if content.length <= 0
    @error = 'Enter text...'
    # если ввели пустое значение, ошибка и на повтор ввода
    return erb :new
  end

  # запись в БД данных
  @db.execute 'INSERT INTO Posts (content, created_date) VALUES (?, datetime())', [content]

  # перенаправление на главную страницу
  redirect to '/'

  #erb "You typed: #{content}"
end

# вывод всех постов
get '/' do
  @post_list=@db.execute 'SELECT * FROM Posts ORDER BY id desc' 
  erb :index
end
















# configure do
#   enable :sessions
# end

# helpers do
#   def username
#     session[:identity] ? session[:identity] : 'Hello stranger'
#   end
# end

# before '/secure/*' do
#   unless session[:identity]
#     session[:previous_url] = request.path
#     @error = 'Sorry, you need to be logged in to visit ' + request.path
#     halt erb(:login_form)
#   end
# end

# get '/' do
#   erb 'Can you handle a <a href="/secure/place">secret</a>?'
# end

# get '/login/form' do
#   erb :login_form
# end

# post '/login/attempt' do
#   session[:identity] = params['username']
#   where_user_came_from = session[:previous_url] || '/'
#   redirect to where_user_came_from
# end

# get '/logout' do
#   session.delete(:identity)
#   erb "<div class='alert alert-message'>Logged out</div>"
# end

# get '/secure/place' do
#   erb 'This is a secret place that only <%=session[:identity]%> has access to!'
# end
