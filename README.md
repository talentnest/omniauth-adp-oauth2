[![Gem Version](https://badge.fury.io/rb/omniauth-adp-oauth2.svg)](https://badge.fury.io/rb/omniauth-adp-oauth2)
[![Code Climate](https://codeclimate.com/github/dahal/omniauth-adp-oauth2/badges/gpa.svg)](https://codeclimate.com/github/dahal/omniauth-adp-oauth2)
[![Issue Count](https://codeclimate.com/github/dahal/omniauth-adp-oauth2/badges/issue_count.svg)](https://codeclimate.com/github/dahal/omniauth-adp-oauth2)

# OmniAuth ADP OAuth2 Strategy

Strategy to authenticate with ADP via OpenID CConnect in OmniAuth.

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-adp-oauth2'
```

Then `bundle install`.


## Usage

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :adp_oauth2, ENV["ADP_CONSUMER_CLIENT_ID"], ENV["ADP_CONSUMER_CLIENT_SECRET"]
end
```

### Devise

First define your application id and secret in `config/initializers/devise.rb`.

```ruby
config.omniauth :adp_oauth2, "ADP_CONSUMER_CLIENT_ID", "ADP_CONSUMER_CLIENT_SECRET", { }
```

Then add the following to 'config/routes.rb' so the callback routes are defined.

```ruby
devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
```

Make sure your model is omniauthable. Generally this is "/app/models/user.rb"

```ruby
devise :omniauthable, :omniauth_providers => [:adp_oauth2]
```

Then make sure your callbacks controller is setup.

```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def adp_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "ADP"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.adp_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
end
```

and bind to or create the user

```ruby
def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(name: data["name"],
    #        email: data["email"],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
    user
end
```

For your views you can login using:

```erb
<%= link_to "Sign in with ADP", user_adp_oauth2_omniauth_authorize_path %>

<%# Devise prior 4.1.0: %>
<%= link_to "Sign in with ADP", user_omniauth_authorize_path(:adp_oauth2) %>
```

An overview is available at https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview



## Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env["omniauth.auth"]`:

```ruby

```

## Credits

* [omniauth-google-oauth2](https://github.com/zquestz/omniauth-google-oauth2)

## License

Copyright (c) 2016 by Puru Dahal

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
