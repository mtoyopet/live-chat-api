## STEP1

### 1. Railsプロジェクトを作成する

参考: [新規Railsプロジェクトの作成手順まとめ](https://qiita.com/yuitnnn/items/b45bba658d86eabdbb26)

1. `mkdir live-chat-api` 
2. Gemファイルで`gem "rails"`を`gem 'rails', '~> 6.0.0'`に変更
3. `bundle install --path vendor/bundle`
4. Railsアプリを作成 `bundle exec rails new . --api`
  - `Overwrite /Users/mtoyopet/code/personal-project/2021/techpit/live-chat-api/Gemfile?` は`Y`を選択

### 2. ログイン機能を実装する

参考: [Rails6.0とdevice_token_auth でトークンベースで認証を実装する](https://qiita.com/mtoyopet/items/076b623ac72f4f83c5f6)

**Deviseとdevise token authの導入**

1. deviseとdevise_token_authをGemfileに追加。rubygems.orgから最新を追加すること
2. `bundle install`、`bundle exec rails g devise:install`を実行
    ```
    Running via Spring preloader in process 45327
      conflict  config/initializers/devise.rb
    Overwrite /Users/mtoyopet/code/personal-project/2021/techpit/live-chat-api/config/initializers/devise.rb? (enter "h" for help) [Ynaqdhm] Y
          force  config/initializers/devise.rb
      identical  config/locales/devise.en.yml
    ===============================================================================

    Depending on your application's configuration some manual setup may be required:

    1. Ensure you have defined default url options in your environments files. Here
      is an example of default_url_options appropriate for a development environment
      in config/environments/development.rb:

        config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

      In production, :host should be set to the actual host of your application.

      * Required for all applications. *

    2. Ensure you have defined root_url to *something* in your config/routes.rb.
      For example:

        root to: "home#index"
      
      * Not required for API-only Applications *

    3. Ensure you have flash messages in app/views/layouts/application.html.erb.
      For example:

        <p class="notice"><%= notice %></p>
        <p class="alert"><%= alert %></p>

      * Not required for API-only Applications *

    4. You can copy Devise views (for customization) to your app by running:

        rails g devise:views
        
      * Not required *

    ===============================================================================
    ```
3. `bundle exec rails g devise_token_auth:install User auth`を実行
    ```
    Running via Spring preloader in process 45488
    create  config/initializers/devise_token_auth.rb
    insert  app/controllers/application_controller.rb
      gsub  config/routes.rb
    create  db/migrate/20210505052353_devise_token_auth_create_users.rb
    create  app/models/user.rb
    ```
4. xxxxx_devise_token_auth_create_users.rbを開いて、`Revcoverable`、`Confirmable`、`Lockable`と下三行をコメントアウトする
5. `bundle exec rails db:migrate`
    ```
    == 20210505052353 DeviseTokenAuthCreateUsers: migrating =======================
    -- create_table(:users)
      -> 0.0047s
    -- add_index(:users, :email, {:unique=>true})
      -> 0.0022s
    -- add_index(:users, [:uid, :provider], {:unique=>true})
      -> 0.0041s
    == 20210505052353 DeviseTokenAuthCreateUsers: migrated (0.0113s) ==============
    ```
6. `config/initializers/devise_token_auth.rb`を開き、[ここの通り](https://qiita.com/mtoyopet/items/076b623ac72f4f83c5f6#1devise_token_authrb%E3%81%AE%E8%A8%AD%E5%AE%9A)設定する
7. `application_controller.rb`に`include DeviseTokenAuth::Concerns::SetUserByToken`があるか確認する

**CORSの設定**

8. `rack-cors`をGemfileに追加し、`bundle install`
9. `config/application.rb`に[この設定](https://qiita.com/mtoyopet/items/076b623ac72f4f83c5f6#3applicationrb%E3%81%AE%E8%A8%AD%E5%AE%9A)を追加する

**ルートの設定**

10. `routes.rb`を開き、下記をごっそりコピペする
  - `DeviseTokenAuth::RegistrationsController`クラスを継承
  - `sign_up_params`の設定

    ```
    class Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController

      private

      def sign_up_params
        params.permit(:name, :email, :password, :password_confirmation)
      end
    end
    ```

**コントローラの設定**

11. `bundle exec rails g controller auth/registrations`を実行する
    ```
    Running via Spring preloader in process 46310
      create  app/controllers/auth/registrations_controller.rb
      invoke  test_unit
      create    test/controllers/auth/registrations_controller_test.rb
    ```
12. `controllers/auth/registrations_controller.rb`にsign_up_paramsを追加

**POSTMANでテスト**

13. `bundle exec rails s`でサーバを起動
14. Create / SignIn / Change Password

## STEP2: Vueアプリの作成

