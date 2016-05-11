# Homepage (Root path)
require 'securerandom'
require 'pry'
enable :sessions

#this is home page
get '/' do
  @user = User.find_by_session_token(session[:session_token])
  erb :index
end

get '/login' do
  erb :login
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/signup' do
  erb :'signup'
end

get '/welcome' do
  @user = User.find_by_session_token(session[:session_token])
  erb :'welcome'
end

get '/profilepage' do
  @user = User.find_by_session_token(session[:session_token])
  erb :'profilepage'
end

get "/create" do
  @user = User.find_by_session_token(session[:session_token])
  @sport = Sport.find_by(id: session[:sport_id])
  erb :'create'
end  

get "/match" do
  @user = User.find_by_session_token(session[:session_token])
  @sport = Sport.find_by(id: session[:sport_id])
  @matches = @sport.matches.select do |match| 
    match.player_one_id != @user.id && match.player_two_id == nil
  end
  @mymatches = @sport.matches.select do |mymatch|
    mymatch.player_one_id == @user.id && mymatch.player_two_id == nil
  end
  erb :'match'
end

get "/match/:id" do
  @user = User.find_by_session_token(session[:session_token])
  @match = Match.find params[:id]
  erb :'show'
end

get "/match/:id/review" do
  @user = User.find_by_session_token(session[:session_token])
  @match = Match.find params[:id]
  erb :'review'
end

get "/match_history" do
  @user = User.find_by_session_token(session[:session_token])
  @matches = Match.all.select do |match|
    ((@user.id == match.player_one_id) || (@user.id == match.player_two_id)) && (match.player_one_id != nil && match.player_two_id != nil) 
  end
  erb :'match_history'
end

def user_authenticate!
  redirect '/login' unless session.has_key?(:session_token)
  if !session.has_key?(:user_session) || !User.find_by_session_token(session[:session_token])
    redirect '/login'
  end
end

post '/signup' do
      @user = User.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      username: params[:username],
      password: params[:password],
      email: params[:email],
      phone: params[:phone],
      birthday: params[:birthday],
      profile_pic: params[:profile_pic]
      )
      if @user.save
        redirect '/login'
      else
        erb :'/401'
     end   
end

post '/session' do
  user = User.find_by_username(params[:username])
  if user && user.authenticate(params[:password])
    session[:session_token] = SecureRandom.urlsafe_base64()
    user.update!(session_token: session[:session_token])
    redirect '/welcome'
  else
    redirect '/login'
  end
end

post "/upload" do 
  @user = User.find_by_session_token(session[:session_token])
  filename = @user.id.to_s
  filepath = 'public/uploads/'
  if (params['myfile'][:type] == "image/jpg" || params['myfile'][:type] == "image/jpeg" )
    filename += ".jpg"
  elsif  (params['myfile'][:type] == "image/png")
      filename += ".png"
  else
    return "Invalid file"
  end
  File.open(filepath + filename, "w") do |f|
  f.write(params['myfile'][:tempfile].read)
  @user.update!(profile_pic: filename )
  end
    redirect '/profilepage'
end

post '/choice' do
  session[:sport_id] = params[:sport_id]
  redirect '/match'
end

post '/new_match' do
  @user = User.find_by_session_token(session[:session_token])
  @match = Match.create(
    sport_id: session[:sport_id],
    address: params[:address],
    start_time: params[:start_time],
    end_time: params[:end_time],
    player_one_id: @user.id
  )
  redirect '/match'
end

post '/challenge/:id' do 
  @user = User.find_by_session_token(session[:session_token])
  @match = Match.find (params[:id])
  @match.player_two_id = @user.id
  # binding.pry
  @match.save
  redirect "/match/#{@match.id}"
end

post "/match/:id/review" do
    @user = User.find_by_session_token(session[:session_token])
    # @match = Match.find_by(id: session[:match_id])
    # @match = Match.find_by(params [:id])
    # binding.pry
    # grab star rating  
    @match = Match.find params[:id]
    # @review_rating = params[:star]
    Review.create(from_user_id: @match.player_two_id, to_user_id: @match.player_one_id, rating: params[:star], match_id: @match.id, comments: params[:comm])
    redirect "/match/#{@match.id}"
end

get '/session/sign_out' do
  User.find_by_session_token(session[:session_token]).update!(session_token: nil)
  session.clear
  redirect '/login'
end

post '/match/:id/delete_match' do
  @user = User.find_by_session_token(session[:session_token])
  @match = Match.find params[:id]
  @match.destroy
  redirect "/match"
end
