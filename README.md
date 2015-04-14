# Ans::Labelizer

include 時に、 I18n の translate メソッドを使用してラベルを取得して、ラベルを取得するメソッドを定義します

## Installation

Add this line to your application's Gemfile:

    gem 'ans-labelizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ans-labelizer

## Usage

    # config/locale/flags.yml
    ja:
      activerecord:
        flags:
          yes_no: &yes_no
            true: "yes"
            false: "no"
          my_model:
            my_flag:
              0: {none: "無し"}
              1: {my_flag: "あり"}
              2: {other_flag: "その他"}
            is_flag:
              true: "はい"
              false: "いいえ"
            is_ok:
              <<: *yes_no

    class MyModel
      include Ans::Labelizer
    end

MyModel の `my_flag`, `is_flag`, `is_ok` カラムのラベルを以下のように取得できる

クラスメソッド

    MyModel.my_flag_labels # => {0 => "無し", 1 => "あり", 2 => "その他"}
    MyModel.my_flag_names # => {0 => :none, 1 => :my_flag, 2 => :other_flag}
    MyModel.my_flag_keys # => {"無し" => 0, "あり" => 1, "その他" => 2}
    MyModel.my_flag_name_keys # => {:none => 0, :my_flag => 1, :other_flag => 2}

    MyModel.my_flag_values(:none,:my_flag) # => [0, 1] # name が :none か :my_flag の値を取得

    MyModel.my_flag_of(:my_flag) # => 1
    MyModel.my_flag_my_flag # => 1

    MyModel.labelizer_flags
    {
      my_flag: {
        name: {0 => :none, 1 => :my_flag, 2 => :other_flag},
        label: {0 => "無し", 1 => "あり", 2 => "その他"},
        name_inverse: {:none => 0, :my_flag => 1, :other_flag => 2},
        label_inverse: {:none => 0, :my_flag => 1, :other_flag => 2},
      },
      ...
    }

インスタンスメソッド

    item = MyModel.find(id)

    item.my_flag # => 2
    item.my_flag_label # => "その他"
    item.my_flag_name # => :other_flag
    item.my_flag_my_flag # => 1 :my_flag の値を返す
    item.my_flag_other_flag? # => true (全ての name に対してメソッドが定義される)
    item.my_flag_my_flag! # => item.my_flag を 1 (name: my_flag) に設定

    item.my_flag_of(:my_flag) # => 1
    item.my_flag_is?(:other_flag) # => true
    item.my_flag_name = :my_flag # => item.my_flag を 1 (name: other_flag) に設定

    item.is_flag # => true
    item.is_flag_label # => "はい"
    item.is_flag_name # => nil (未設定の場合は nil)

    item.is_ok # => false
    item.is_ok_label # => no
    item.is_ok_name # => nil

Hash の `[]` メソッドの呼び出しを行っているため、キーが存在しない場合は nil が帰る

yaml のラベル部分を {name: label} のように定義すると、このハッシュの key 部分を name 、 value 部分を label として認識する  
name にはプログラムで使用するようなアルファベットの名前を、 label には表示用の名前を指定する  
キー部分の型は、 yaml がパースしたままの型で返されるので、文字列や boolean などの型になるように yaml を記述するとそのように取得されるはず

全てのフラグに name に相当するものがあるわけではないので、その場合は name を省略して書ける

いくつかのフラグ間でラベルを共有したい場合がままある

yaml のマージを利用すると解消できるが、そのためにはフラグの定義を 1ファイル で行う必要がある

フラグの設定を追加した場合、アプリケーションサーバーの再起動が必要

## Setting

可能な設定とデフォルト

    # config/initializers/ans-labelizer.rb
    Ans::Labelizer.configure do |config|

      # locale を検索するパスを設定
      # この後ろに model_name.underscore した文字列を連結して全フラグを取得する
      config.locale_path = "activerecord.flags"

      # フラグラベルのハッシュを取得するクラスメソッドの接尾辞
      config.hash_method_suffix = "_labels"
      # フラグ名のハッシュを取得するクラスメソッドの接尾辞
      config.name_hash_method_suffix = "_names"
      # フラグラベルハッシュを invert したものを取得するクラスメソッドの接尾辞
      config.inverse_method_suffix = "_keys"
      # フラグ名ハッシュを invert したものを取得するクラスメソッドの接尾辞
      config.name_inverse_method_suffix = "_name_keys"

      # フラグ名から値を取得するクラスメソッドの接尾辞
      config.values_method_suffix = "_values"

      # フラグのラベルを取得するインスタンスメソッドの接尾辞
      config.label_method_suffix = "_label"
      # フラグの名前を取得するインスタンスメソッドの接尾辞
      config.name_method_suffix = "_name"
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
