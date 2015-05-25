# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ans-labelizer/version'

Gem::Specification.new do |gem|
  gem.name          = "ans-labelizer"
  gem.version       = "2.0.6"
  gem.authors       = ["sakai shunsuke"]
  gem.email         = ["sakai@ans-web.co.jp"]
  gem.description   = %q{all_flags 的なカラムのラベルを取得するメソッドを追加する}
  gem.summary       = %q{model 用の locale 設定を読み込んで、ラベルメソッドを追加する}
  gem.homepage      = "https://github.com/answer/ans-labelizer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
