class UserMailer < SuperMailer


  def test_email( email )
    m = mail( :to => email, :subject => 'VersionEye Test Email' )
    set_from( m )
  end


  def verification_email(user, verification, email)
    @user  = user
    source = fetch_source( user )
    @verificationlink = "#{Settings.instance.server_url}/users/activate/#{source}/#{verification}"
    m = mail( :to => email, :subject => 'Verification' ) do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def verification_email_only(user, verification, email)
    @user = user
    @verificationlink = "#{Settings.instance.server_url}/users/activate/email/#{verification}"
    m = mail(:to => email, :subject => 'Verification') do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def invited_user_author( user, authors )
    @user    = user
    @authors = authors
    m = mail( :to => user.email, :subject => "Edit your VersionEye pages." ) do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def reset_password(user)
    @user = user
    @url  = "#{Settings.instance.server_url}/updatepassword/#{@user.verification}"
    m = mail(:to => @user.email, :subject => 'Password Reset') do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def non_profit_signup( user, np_domain )
    @user = user
    @npd  = np_domain
    m = mail(:to => user[:email], :subject => "You got #{np_domain.free_projects} private projects at VersionEye for free!") do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def project_removed( user, project )
    @user    = user
    @project = project
    m = mail(:to => user.email, :subject => "Project #{project.name} removed") do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def deleted( user, why )
    @user = user
    @why = why
    m = mail(:to => 'reiz@versioneye.com', :subject => "User #{user.fullname} deleted") do |format|
      format.html{ render layout: 'email_html_layout' }
    end
    set_from( m )
  end


  def fetch_source( user )
    source = "email"
    source = "bitbucket" if user.bitbucket_id
    source = "github"    if user.github_id
    source
  end


end
