## STEP1: Railsアプリの作成

### Railsプロジェクトを作成する

参考: [新規Railsプロジェクトの作成手順まとめ](https://qiita.com/yuitnnn/items/b45bba658d86eabdbb26)

1. `mkdir live-chat-api` 
2. Gemファイルで`gem "rails"`を`gem 'rails', '~> 6.0.0'`に変更
3. `bundle install --path vendor/bundle`
4. Railsアプリを作成 `bundle exec rails new . --api`
    - `Overwrite /Users/mtoyopet/code/personal-project/2021/techpit/live-chat-api/Gemfile?` は`Y`を選択

### ログイン機能を実装する

参考: [Rails6.0とdevice_token_auth でトークンベースで認証を実装する](https://qiita.com/mtoyopet/items/076b623ac72f4f83c5f6)

### Deviseとdevise token authの導入

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

### CORSの設定

8. `rack-cors`をGemfileに追加し、`bundle install`
9. `config/application.rb`に[この設定](https://qiita.com/mtoyopet/items/076b623ac72f4f83c5f6#3applicationrb%E3%81%AE%E8%A8%AD%E5%AE%9A)を追加する

### ルートの設定

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

### コントローラの設定

11. `bundle exec rails g controller auth/registrations`を実行する
    ```
    Running via Spring preloader in process 46310
      create  app/controllers/auth/registrations_controller.rb
      invoke  test_unit
      create    test/controllers/auth/registrations_controller_test.rb
    ```
12. `controllers/auth/registrations_controller.rb`にsign_up_paramsを追加

### POSTMANでテスト

13. `bundle exec rails s`でサーバを起動
14. Create / SignIn / Change Password

## STEP2: Vueアプリの作成

### アプリの作成

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

### Welcomeページの作成

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
   
### サインアップとログインページの作成
 
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
 
### ログインページの作成
 
16. `LoginForm.vue`を`components/`に追加
17. `LoginForm`に実装
    ```
      <template>
        <h2>ログイン</h2>
        <form @submit.prevent="handleSubmit">
          <input type="email" required placeholder="メールアドレス" v-model="email">
          <input type="password" required placeholder="パスワード" v-model="password">
          <button>ログインする</button>    
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

### ログインとサインインフォームの切り替えを行う

18. v-ifを入れて画面の切り替えを行う
    ```
    <template>
      <div class="container welcome">
        <p>ようこそ</p>
        <div v-if="shouldShowLoginForm">
          <login-form />
          <p>アカウントがありませんか？アカウント登録は<span @click="shouldShowLoginForm = false">こちら</span>をクリック</p>
        </div>
        <div v-if="!shouldShowLoginForm">
          <signup-form />
          <p>アカウントをお持ちですか？ログインは<span @click="shouldShowLoginForm = true">こちら</span>をクリック</p>
        </div>
      </div>
    </template>

    <script>
    import LoginForm from '../components/LoginForm.vue'
    import SignupForm from "../components/SignupForm.vue"
    import { ref } from 'vue'

    export default  {
      components: { SignupForm, LoginForm },
      setup() {
        const shouldShowLoginForm = ref(true)

        return { shouldShowLoginForm }
      }
    }
    </script>    
    ```


## STEP3: サインアップとログイン機能の実装
参考： [How do i use this with vue](https://github.com/lynndylanhurley/devise_token_auth/issues/844)

19. axiosをインストール `npm install axios vue-axios`
    - [公式ドキュメント](https://www.npmjs.com/package/vue-axios)
20. `main.js`を書き換える
    ```
    import { createApp } from 'vue'
    import App from './App.vue'
    import router from './router'
    import axios from 'axios'
    import VueAxios from 'vue-axios'

    import './assets/main.css'

    const app = createApp(App).use(router).mount('#app')
    app.use(VueAxios, axios)
    ```
 21. `SignupForm.vue`にaxiosをインポートしてRailsとつなげる。Headersをconsole.logして必要なAuthデータが返ってくることを確かめる
 22. `composables`ディレクトリを作って、`useSignup.js`にサインアップメソッドを移動させる（いらないかも）
 23. アカウント登録に失敗した場合のエラーメッセージを表示する
 

### ログイン機能の実装

24. `composables/`に`useLogin.js`を作成、`useSignin.js`をコピペして内容を書き換える
25. `LoginForm.vue`を書き換え、ログインのテスト。ヘッダーが返ってくることをconsole.logして確かめる
26. ログインに失敗した場合のエラーメッセージを表示する


### サインインとログイン成功時にリダイレクトさせる

27. `views/`に`Chatroom.vue`を作成する
28. `router/index.js`にチャットルームを作成し、アクセスできるか確認する
29. `LoginForm.vue`と`Welcome.vue`にemitイベントを追加。リダイレクトするか確認する
30. `SignupForm.vue`と`Welcome.vue`にemitイベントを追加。リダイレクトするか確認する


### Auth情報を保存する

31. `window.localStorage.setItem`を用いて、auth情報をローカルストレージに保存するメソッドを`useLogin.js`に追加する
32. localstorageに保存されていることを確認する
33. nameはbodyにあるので、bodyからとる
34. `useSignin.js`にも同じ実装をする。localStorageが上書きされることを確かめる
35. `auth/setItem.js`を作って、localStorage系のメソッドを共通化する。`useLogin.js`と`useSignin.js`でimportする


## STEP4: ログアウト機能の実装

### ナビバーの作成

36. `components/`に`Navbar.vue`を作成して下記を作成
    ```
    <template>
      <nav>
        <div>
          <p>こんにちは、XXさん</p>
          <p class="email">現在、....@...comでログイン中です</p>
        </div>
        <button>ログアウト</button>
      </nav>
    </template>

    <script>
    export default {

    }
    </script>


    <style scoped>
      nav {
        padding: 20px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      nav p {
        margin: 2px auto;
        font-size: 16px;
        color: #444;
      }
      nav p.email {
        font-size: 14px;
        color: #999;
      }
    </style>
    ```
37. Chatroom.vueでimportする
38. localStorageから名前とメールアドレスを取り出しNavbarに表示させる

### ログアウトロジックの実装

40. `composables/useLogout.js`を作成しロジックを書く
41. `Navbar.vue`に`useLogout.js`をimportする
42. `handleClick`でメソッドを動かして、ログアウトされることを確認する。localStorageも空になっていることを確認する
43. ログアウトした時に、Welcomeにリダイレクトされるようにemitイベントを実装する


## STEP5: ルートガードを設定する

44. `router/index.js`に`requireNoAuth`と`requireAuth`メソッドを追加する
45. `auth/`にvalidateメソッドを追加する
46. consoleでエラーが出ているはずなので、localstorageのuidがnilの場合は、`validate`メソッドは動かないように分岐を入れる
47. ログインしている場合、していない場合でページに入れる・入れないことを確認する


## STEP6: チャット機能の実装：一覧表示

- 参考: [RailsのAction CableとWebpackerとVue.jsを使ってチャットを作成してみる](http://c5meru.hatenablog.jp/entry/2018/10/16/230000)

### モデルの作成

48. `bundle exec rails g model message`でモデルを作成
49. migrationファイルを作成
50. MessageモデルとUserモデルにリレーションを追加
51. Messageモデルにvalidationを追加
52. `bundle exec rails db:migrate`
    ```
    == 20210507042335 CreateMessages: migrating ===================================
    -- create_table(:messages)
       -> 0.0111s
    == 20210507042335 CreateMessages: migrated (0.0122s) ==========================
    ```

### コントローラとビューを作成

53. `bundle exec rails g controller messages`
    ```
    Running via Spring preloader in process 73257
      create  app/controllers/messages_controller.rb
      invoke  test_unit
      create    test/controllers/messages_controller_test.rb
    ```
54. indexメソッドを作成
55. POSTMANでテストする。空の配列が返ってくる
56. seeds.rbを作り、`bundle exec rails db:seed`
    ```
    0番目のメッセージを作成しました
    1番目のメッセージを作成しました
    2番目のメッセージを作成しました
    メッセージを作成が完了しました
    ```
57. もう一度Postmanでテストして配列データが返ってくることを確認する
58. user_nameが入っていないので、配列を作り直す。user_nameが入っていることを確認する

### ログインしていないとメッセージを受け取れないようにする

59. `before_action :authenticate_user!`を追加し、Postmanで確認する
60. ヘッダーにauth情報を入れてもう一度リクエストする

### メッセージを表示する

61. `ChatWindow.vue`を作成し、getMessagesメソッドを実装する。
62. `ChatRoom.vue`にimportし、データが表示されることを確認する
63. CSSを追加して見た目を整える


## STEP7: チャット機能の実装： メッセージの作成

- 参考： [Rails(ActionCable)とNuxt.jsでチャットアプリを作ってみる](https://qiita.com/daitasu/items/d018fba8d3daa51ecf51)

### Action Cableの作成

64. `bundle exec rails g channel post speak`
    ```
    Running via Spring preloader in process 79728
      invoke  test_unit
      create    test/channels/post_channel_test.rb
      create  app/channels/post_channel.rb
    ```
65. `room_channel.rb`を書き換える
    ```
    class RoomChannel < ApplicationCable::Channel
      def subscribed
        stream_from 'room_channel'
      end

      def unsubscribed
        # Any cleanup needed when channel is unsubscribed
      end

      def receive(data)
          ActionCable.server.broadcast 'room_channel', message: data['message'], name: user.name, created_at: message.created_at
      end
    end
    ```
66. ` npm install -g wscat`でインストール
67. `config/initializers`に`action_cable.rb`を作成し、`ActionCable.server.config.disable_request_forgery_protection = true`を追加する
68. Railsサーバーを立ち上げて、`wscat -c ws://localhost:3000/cable`が動くかテストする
 

### フロント側の実装

- 参考: [Creating a Chat Using Rails' Action Cable](https://www.pluralsight.com/guides/creating-a-chat-using-rails-action-cable)

69. `NewChatForm.vue`を作成し、ChatRoom.vueにimportする
70. CSSを適用する
71. `npm install actioncable-vue --save`
72. `main.js`にaction cableの設定を追加する
73. ActionCableのメソッドを実装する
74. receivedでalertが出るか確認する

### メッセージをDBに保存する

75. RailsのReceiveメソッドを書き換える
    ```
      def receive(data)
        user = User.find_by(email: data['uid'])

        if message = Message.create(content: data['message'], user_id: user.id)
          ActionCable.server.broadcast 'room_channel', message: data['message'], name: user.name, created_at: message.created_at
        end
      end
    ```
76. メッセージを送って、リロードするとメッセージが表示されることを確認する
77. `NewChatForm.vue`のgetMessagesを親コンポーネントの`ChatRoom.vue`に移動し、messagesをpropsで渡す
78. チャットを送る度にメッセージが追加されることを確認する


### サブスクライブを削除する
79. beforeDestoryでchannelをunsubscribeする

## STEP8: 最終調整

### Dateフォーマットを整える

80. `npm install date-fns --save`
81. `Chatroom.vue`にformattedMessagesのcomputedを定義、formattedMessagesをpropsで渡す
82. 英語で表示されることを確認する
83. localeを追加して日本語表記にする

### スクロールする

84. `ChatWindow.vue`にupdatedメソッドを追加する

 
