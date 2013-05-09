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
            yes_no: &yes_no
                true: "yes"
                false: "no"
            my_model:
                flags:
                    my_flag:
                        0: "無し"
                        1: "あり"
                        2: "その他"
                    is_flag:
                        true: "はい"
                        false: "いいえ"
                    is_ok:
                        <<: *yes_no

    class MyModel
        include Ans::Labelizer
    end
    
MyModel に `my_flag`, `is_flag`, `is_ok` カラムのラベルを以下のように取得できる

    MyModel.my_flag_labels # => {0 => "無し", 1 => "あり", 2 => "その他"}
    MyModel.my_flag_keys # => {"無し" => 0, "あり" => 1, "その他" => 2}

    item = MyModel.find(id)

    item.my_flag # => 2
    item.my_flag_label # => "その他"

    item.is_flag # => true
    item.is_flag_label # => "はい"

    item.is_ok # => false
    item.is_ok_label # => no

いくつかのフラグ間でラベルを共有したい場合がままある

yaml のマージを利用すると解消できるが、そのためにはフラグの定義を 1ファイル で行う必要がある

## Setting

可能な設定とデフォルト

    # config/initializers/ans-labelizer.rb
    Ans::Labelizer.configure do |config|

        # locale を検索するパスを設定
        # この後ろに model_name.underscore した文字列を連結して全フラグを取得する
        config.locale_path = "activerecord.flags"

        # フラグラベルのハッシュを取得するクラスメソッドの接尾辞
        config.hash_method_suffix = "_labels"
        # ハッシュを invert したものを取得するクラスメソッドの接尾辞
        config.inverse_method_suffix = "_keys"

        # フラグのラベルを取得するインスタンスメソッドの接尾辞
        config.label_method_suffix = "_label"

    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
