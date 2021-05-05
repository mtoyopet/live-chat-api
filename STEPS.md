## STEP1: Railsアプリの作成

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

**アプリの作成**

1. `vue create live-chat-front`
   ```
   Vue CLI v4.5.12
    ? Please pick a preset: Manually select features
    ? Check the features needed for your project: Choose Vue version, Babel, Router
    ? Choose a version of Vue.js that you want to start the project with 3.x (Preview)
    ? Use history mode for router? (Requires proper server setup for index fallback in production) Yes
    ? Where do you prefer placing config for Babel, ESLint, etc.? In package.json
    ? Save this as a preset for future projects? No
   ```
2. `cd live-chat-front`、`npm run serve`
3. VueプロジェクトがVer3か確認する
4. `HelloWorld.vue`、`About.vue`、`Home.vue`を削除
5. `App.vue`を下記に変更
    ```
    <template>
      <router-view/>
    </template>
    ```
6. `router/index.js`
    - routes内を削除して`const routes = []`に変更
    - `import Home from '../views/Home.vue'`を削除

**Welcomeページの作成**

7. `Welcome.vue`を`view`内に作成
8. `Welcome.vue`を編集
      ```
      <template>
        <div class="container welcome">
          <p>Welcome!!!!</p>
        </div>
      </template>

      <script>
      export default {

      }
      </script>

      <style scoped>
        .welcome {
          text-align: center;
          padding: 20px 0;
        }
      </style>
      ```
9. `router/index.js`にwelcomeを登録
    ```
    import Welcome from '../views/Welcome'

    const routes = [
      {
        path: '/',
        name: 'Welcome',
        component: Welcome
      }
    ]
    ```
10. main.cssを`/assets`に追加
11. main.cssを`Main.js`でimportする
   
 **サインアップページの作成**
 
 12. `/components`配下に`SignupForm.vue`を作成する
 13. `Welcome`ページで`SignupForm.vue`をimportする
 14. `SignupForm.vue`の修正
      ```
      <template>
        <h2>アカウントを登録</h2>
        <form @submit.prevent="handleSubmit">
          <input type="text" required placeholder="名前" v-model="name">
          <input type="email" required placeholder="メールアドレス" v-model="email">
          <input type="password" required placeholder="パスワード" v-model="password">
          <input type="password" required placeholder="パスワード（確認用）" v-model="passwordConfirmation">
          <button>登録する</button>    
        </form>
      </template>

      <script>
      import { ref } from 'vue'

      export default {
        setup() {
          const name = ref('')
          const email = ref('')
          const password = ref('')
          const passwordConfirmation = ref('')

          const handleSubmit = () => {
            console.log({ name, email, password, passwordConfirmation })
          }

          return { name, email, password, passwordConfirmation, handleSubmit }
        }
      }
      </script>
      ```
  15. CSSを`Welcome.vue`に追加
      ```
      /* フォームのスタイル */
      .welcome form {
        width: 300px;
        margin: 20px auto;
      }
      .welcome label {
        display: block;
        margin: 20px 0 10px;
      }
      .welcome input {
        width: 100%;
        padding: 10px;
        border-radius: 20px;
        border: 1px solid #eee;
        outline: none;
        color: #999;
        margin: 10px auto;
      }
      .welcome span{
        font-weight: bold;
        text-decoration: underline;
        cursor: pointer;
      }
      .welcome button {
        margin: 20px auto;
      }
      ```
 
 **ログインページの作成**
 
 16. `LoginForm.vue`を`components/`に追加
 17. `LoginForm`に実装
     ```
        <template>
          <h2>ログイン</h2>
          <form @submit.prevent="handleSubmit">
            <input type="email" required placeholder="メールアドレス" v-model="email">
            <input type="password" required placeholder="パスワード" v-model="password">
            <button>登録する</button>    
          </form>
        </template>

        <script>
        import { ref } from 'vue'

        export default {
          setup() {
            const email = ref('')
            const password = ref('')

            const handleSubmit = () => {
              console.log({ email, password })
            }

            return { email, password, handleSubmit }
          }
        }
        </script>
     ```
 
 
     
   
