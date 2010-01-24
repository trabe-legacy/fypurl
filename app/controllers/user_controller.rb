class UserController < ApplicationController

  include AuthenticatedSystem

  before_filter :login_required,
    :only => [:index, :logout, :fyp_express, :unfyp_express, :fyp, :unfyp, :change_password]

  verify :method => :post,
         :only => [:login],
         :redirect_to => {:controller => 'public', :action => 'index'}

  #
  #
  #
  def index
  end

  #
  #
  #
  def go_to_url
    user = User.find_by_login(params[:user])
    if user.nil?
      redirect_to :controller => 'public', :action => 'user_unknown'
    elsif user.url.nil? || user.url.empty?
      redirect_to :controller => 'public', :action => 'no_url'
    else
      redirect_to user.url
    end
  end

  #
  #
  #
  def login
    @login = params[:login]
    self.current_user = User.authenticate(@login, params[:password])
    if logged_in?
      self.current_user.remember_me
      cookies[:auth_token] = { :value =>  self.current_user.remember_token,
                               :expires => self.current_user.remember_token_expires_at }

      flash[:notice] = 'Logged in successfully'
      redirect_to :controller => 'user', :action => 'index'
    else
      flash[:login_user] = @login
      flash[:error] = 'Login failed. Are you sure you\'re using the right <strong>credentials</strong>?'
      redirect_to :controller => 'public', :action => 'index'
    end
  end

  #
  #
  #
  def signup
    @user = User.new(params[:user])
    return unless request.post?

    @user.new_password = true
    @user.save!
    @user.new_password = false
    current_user = @user
    flash[:notice] = "Thanks for signing up!, You need to activate your account. " +
      "We\'ve sent you an e-mail with further instructions"

    redirect_to :controller => 'public', :action => 'index'
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  #
  #
  #
  def activate
    if params[:activation_code]
      @user = User.find_by_activation_code(params[:activation_code])
      if @user and @user.activate
        self.current_user = @user
        flash[:notice] = "Congratulations, your account has been activated."
        redirect_to :controller => 'user', :action => 'index'
      else
        flash[:error] = "Unable to activate the account.  Did you provide the correct information?"
        redirect_to :controller => 'public', :action => 'index'
      end
    else
      flash.clear
      redirect_to :controller => 'public', :action => 'index'
    end
  end


  #
  #
  #
  #
  def forgotten_password

    if logged_in?
      flash[:notice] = "mmm. How can this be? Why do you need a new password " +
          "when you're already logged in? So, how the hell did you log in?"
      redirect_to(:controller => 'public', :action => 'index') and return
    end

    if request.post?
      @email = params[:email]

      if !@email.nil? && !@email.blank?
        user = User.find_by_email(@email)
        if not user.nil?
          new_password = user.new_random_password
          UserNotifier.deliver_new_password(user, new_password)
          flash[:notice] = "We\'ve sent you an e-mail with your new password"
          redirect_to :controller => 'home', :action => 'index'
        end
      end

      @error = 'The <strong>e-mail</strong> you\'ve provided seems to be wrong. Try again'
    end
  end

  #
  #
  #
  def change_password

    return unless request.post?

    @user = User.new
    change = true
    @old_password = params[:old_password]

    if params[:password].blank?
      @user.errors.add('password','You must provide a <strong>new password</strong>')
      change &= false
    end

    if !params[:password].blank? && (params[:password] != params[:password_confirmation])
      @user.errors.add('password','The <strong>new password</strong> and the <strong>confirmation</strong> do not match')
      change &= false
    end

    if !User.authenticate(current_user.login, params[:old_password])
      @user.errors.add('password','You must provide your <strong>old password</strong>')
      change &= false
    end

    if change
      current_user.new_password = false
      current_user.password_confirmation = params[:password_confirmation]
      current_user.password = params[:password]
      if current_user.save
        current_user.new_password = false
        flash[:notice] = 'Your password has been changed'
        redirect_to :controller => 'user', :action => 'index' and return
      else
         @user =  current_user
      end
    end
  end


  #
  #
  #
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out"
    redirect_to :controller => 'public', :action => 'index'
  end

  #
  #
  #
  def fyp
    do_fyp
    redirect_to(:action => "index")
  end

  #
  #
  #
  def unfyp
    do_unfyp
    redirect_to(:action => "index")
  end

  #
  #
  #
  def fyp_express
    do_fyp
    render(:layout => 'popups')
  end

  #
  #
  #
  def unfyp_express
    do_unfyp
    render(:layout => 'popups')
  end

  def login_express
    if request.post?
      @login = params[:login]
      self.current_user = User.authenticate(@login, params[:password])
      if logged_in?
        self.current_user.remember_me
        cookies[:auth_token] = { :value =>  self.current_user.remember_token,
                                 :expires => self.current_user.remember_token_expires_at }

        redirect_to :controller => 'user', :action => params[:fyp_action], :url => params[:url]
      else
        flash[:login_user] = @login
        flash[:error] = 'Login failed. Are you sure you\'re using the right <strong>credentials</strong>?'

        redirect_to :controller => 'user', :action => 'login_express',
          :fyp_action => params[:fyp_action], :url => params[:url]
      end
    else
      flash[:fyp_action] = params[:fyp_action]
      flash[:url] = params[:url]
      render(:layout => "popups")
    end
  end

  private

  def do_fyp
    if /^(ftp|https?):\/\/((?:[-a-z0-9]+\.)+[a-z]{2,})/ =~ params[:url]
      current_user.url = params[:url]
      current_user.url_time = Time.now.utc

      if !current_user.save
        flash[:error] = 'Something went wrong, sorry...'
        flash[:url] = params[:url]
      else
        flash[:notice] = 'Congratulations! You\'ve fypped the URL!'
      end
    else
      flash[:error] = 'This <strong>URL</strong> is so strange... We think this isn\'t an URL... Maybe we\'re wrong, but, you know...'
      flash[:url] = params[:url]
    end
  end

  def do_unfyp
    current_user.url = nil
    current_user.url_time = nil
    current_user.save
    flash[:notice] = 'Congratulations! You\'ve unfypped the URL!'
  end

  alias :old_access_denied :access_denied

  def access_denied
    if (@action_name == 'fyp_express') ||
       (@action_name == 'unfyp_express')
      flash[:notice] = 'Log in please'
      redirect_to(:controller => "user", :action => "login_express",
        :fyp_action => params[:fyp_action], :url => params[:url])
    else
      old_access_denied
    end
  end
end
