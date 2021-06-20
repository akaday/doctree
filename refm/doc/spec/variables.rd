= 変数と定数

  * [[ref:local]]
  * [[ref:instance]]
  * [[ref:class]]
  * [[ref:class_var_scope]]
  * [[ref:global]]
  * [[ref:pseudo]]
  * [[ref:const]]
  * [[ref:prio]]

Ruby の変数と定数の種別は変数名の最初の一文字によって、
ローカル変数、
インスタンス変数、
クラス変数、
グローバル変数、
定数
のいずれかに区別されます。
通常の変数の二文字目以降は英数字または
_ですが、組み込み変数の一部には
「`$'+1文字の記号」という変数があります([[ref:builtin]]を参照)。変数名
の長さにはメモリのサイズ以外の制限はありません。

===[a:local] ローカル変数

例:

          foobar

小文字または`_'で始まる識別子はローカル変数また
はメソッド呼び出しです。ローカル変数スコープ(クラス、モジュー
ル、メソッド定義の本体)における小文字で始まる識別子への最初
の代入はそのスコープに属するローカル変数の宣言になります。宣
言されていない識別子の参照は引数の無いメソッド呼び出しとみな
されます。

ローカル変数のスコープは、宣言した位置からその変数が宣
言されたブロック、メソッド定義、またはクラス/モジュール定義
の終りまでです。寿命もそのブロックの終りまで(トップレベルの
ローカル変数はプログラムの終了まで)ですが、例外としてブロッ
クが手続きオブジェクト化された場合は、そのオブジェクトが消滅
するまで存在します。同じスコープを参照する手続きオブジェクト
間ではローカル変数は共有されます。

    # (A) の部分はスコープに入らない
    2.times {
      p defined?(v)    # (A)
      v = 1            # ここ(宣言開始)から
      p v              # ここ(ブロックの終り)までが v のスコープ
    }

    # => nil
         1
         nil           <- これが nil であることに注意
         1

宣言は、たとえ実行されなくても宣言とみなされます。

    v = 1 if false # 代入は行われないが宣言は有効
    p defined?(v)  # => "local-variable"
    p v            # => nil

#@until 1.9.1
またあまり推奨はされませんが ruby インタプリタの起動時に -K オプションを指定
すれば日本語文字の識別子も使用でき、それはローカル変数とみなされます。
起動オプションの詳細に関しては[[d:spec/rubycmd]] を参照してください。
#@end

===[a:instance] インスタンス変数

例:

          @foobar

`@'で始まる変数はインスタンス変数であり、特定の
オブジェクトに所属しています。インスタンス変数はそのクラスま
たはサブクラスのメソッドから参照できます。初期化されていない
インスタンス変数を参照した時の値はnilです。


===[a:class] クラス変数

例:

          class Foo
            @@foo = 1
            def bar
              puts @@foo
            end
          end

@@で始まる変数はクラス変数です。クラス変数はクラス定義
の中で定義され、クラスの特異メソッド、インスタンスメソッドなどから参照／
代入ができます。

クラス変数と定数の違いは以下の通りです。

 * 再代入可能(定数は警告を出す)
 * クラスの外から直接参照できない(継承されたクラスからは参照／代入可能)

クラス変数はクラス自身のインスタンス変数とは以下の点で異なります。

 * サブクラスから参照／代入が可能
 * インスタンスメソッドから参照／代入が可能

クラス変数は、そのクラスやサブクラス、それらのインスタンスで共有される
グローバル変数であるとみなすことができます。

        class Foo
          @@foo = 1
        end
        class Bar < Foo
          p @@foo += 1          # => 2
        end
        class Baz < Bar
          p @@foo += 1          # => 3
        end

モジュールで定義されたクラス変数(モジュール変数)は、そのモジュールをイ
ンクルードしたクラス間でも共有されます。

        module Foo
          @@foo = 1
        end
        class Bar
          include Foo
          p @@foo += 1          # => 2
        end
        class Baz
          include Foo
          p @@foo += 1          # => 3
        end

#@until 1.9.0
親クラスに、子クラスで既に定義されている同名のクラス変数を追加した場合には、
子クラスのクラス変数は子クラスで保存されます。上書きされません。

 class Foo
 end

 class Bar < Foo
   @@v = :bar
 end

 class Foo
   @@v = :foo
 end

 class Bar
   p @@v       #=> :bar
 end

 class Foo
   p @@v       #=> :foo
 end

#@end

#@until 3.0.0
親クラスに、子クラスで既に定義されている同名のクラス変数を追加した場合には、
子クラスのクラス変数が上書きされます。

 class Foo
 end

 class Bar < Foo
   @@v = :bar
 end

 class Foo
   @@v = :foo
 end

 class Bar
   p @@v       #=> :foo
 end

#@end

#@since 3.0.0
親クラスに、子クラスで既に定義されている同名のクラス変数を追加した場合、
子クラスが、そのクラス変数を参照した際に例外 [[c:RuntimeError]] が発生します。

 class Foo
 end

 class Bar < Foo
   @@v = :bar
 end

 class Foo
   @@v = :foo
 end

 class Bar
   p @@v       #=> RuntimeError になります。
 end

#@end

====[a:class_var_scope] クラス変数のスコープ

クラス変数は、その場所を囲むもっとも内側の(特異クラスでない) class 式
または module 式のボディをスコープとして持ちます。

#@# http://blade.nagaokaut.ac.jp/cgi-bin/vframe.rb/ruby/ruby-list/39212?39104-39789

 class Foo
   @@a = :a
   class << Foo
     p @@a       #=> :a
   end

   def Foo.a1
     p @@a
   end
 end

 Foo.a1          #=> :a

 def Foo.a2
   p @@a
 end
 Foo.a2          #=> NameError になります。

 class << Foo
   p @@a         #=> NameError になります。
 end


===[a:global] グローバル変数

例:

          $foobar
          $/

`$'で始まる変数はグローバル変数で、プログラムのどこからでも参照できます(その分、利用には注意が必要です)。
グローバル変数には宣言は必要ありません。初期化されていないグローバル変数を参照した時の値はnilです。

====[a:builtin] 組み込み変数
グローバル変数には Ruby 処理系によって特殊な意味を与えられているものがあります。これらを組み込み変数と呼びます。

詳細は [[c:Kernel]] の特殊変数を参照してください。

==== 識別子と分類
組み込み変数の一部は、通常の変数としては使用できない特殊な名前を持っています。

例えば、 $' や $&  あるいは $1, $2, $3 がそうです。
このように 「'$' + 特殊文字一文字」、または「'$' + 10進数字」という名前を持つ変数を特殊変数と呼びます。

また、 $-F や $-I のような変数もあります。
これらは Ruby の起動オプションと -F や -I などと対応しており、オプション変数と呼ばれます。

==== スコープ
組み込み変数は文法解析上はグローバル変数として扱われます。しかし、実際のスコープは必ずしもグローバルとは限りません。

組み込み変数には次の種類のスコープがありえます。

: グローバルスコープ
  通常のグローバル変数と同じ大域的なスコープを持ちます。
: ローカルスコープ
  通常のローカル変数と同じスコープを持ちます。つまり、 class 式本体やメソッド本体で行われた代入はその外側には影響しません。
  プログラム内のすべての場所において代入を行わずともアクセスできることを除いて、通常のローカル変数と同じです。
: スレッドローカルスコープ
  スレッドごとの値を持ちます。他のスレッドで異なる値が割り当てられても影響しません。

また、一部の変数は読み取り専用です。ユーザープログラムから変更することができません。代入しようとすると実行時に例外を生じます。


===[a:pseudo] 疑似変数

通常の変数以外に疑似変数と呼ばれる特殊な変数があります。

: self
  現在のメソッドの実行主体。

: nil
  [[c:NilClass]]クラスの唯一のインスタンス。
  [[m:Object#frozen?]] は true を返します。

: true
  [[c:TrueClass]]クラスの唯一のインスタンス。真の代表値。
  [[m:Object#frozen?]] は true を返します。

: false
  [[c:FalseClass]]クラスの唯一のインスタンス。nilとfalseは偽を表します。
  [[m:Object#frozen?]] は true を返します。

: __FILE__
  現在のソースファイル名

  フルパスとは限らないため、フルパスが必要な場合は
  File.expand_path(__FILE__) とする必要があります。

: __LINE__
  現在のソースファイル中の行番号

: __ENCODING__
  現在のソースファイルのスクリプトエンコーディング

疑似変数の値を変更することはできません。
擬似変数へ代入すると文法エラーになります。

===[a:const] 定数

例:

          FOOBAR
#@since 2.6.0
          ＦＯＯＢＡＲ
#@end

アルファベット大文字 ([A-Z]) で始まる識別子は定数です。
#@since 2.6.0
他にも、ソースエンコーディングが Unicode の時は Unicode の大文字または
タイトルケース文字から始まる識別子も定数です。
Unicode 以外の時は小文字に変換できる文字から始まる識別子が定数です。
#@end
定数の定義 (と初期化) は代入によって行われますが、メソッドの
中では定義できません。一度定義された定数に再び代入を行おうと
すると警告メッセージが出ます。定義されていない定数にアクセス
すると例外 [[c:NameError]] が発生します。

定数はその定数が定義されたクラス/モジュール定義の中(メソッド
本体やネストしたクラス/モジュール定義中を含みます)、クラスを
継承しているクラス、モジュールをインクルードしているクラスま
たはモジュールから参照することができます。クラス定義の外(トッ
プレベル)で定義された定数は [[c:Object]] に所属することになり
ます。

例:

        class Foo
          FOO = 'FOO'       # クラス Foo の定数 FOO を定義(Foo::FOO)
        end

        class Bar < Foo
          BAR = 'BAR'       # クラス Bar の定数 BAR を定義(Bar::BAR)

          # 親クラスの定数は直接参照できる
          p FOO             # => "FOO"
          class Baz

            # ネストしたクラスはクラスの継承関係上は無関係であるがネス
            # トの外側の定数も直接参照できる
            p BAR           # => "BAR"
          end
        end

またクラス定義式はクラスオブジェクトの生成を行うと同時に、
名前がクラス名である定数にクラスオブジェクトを代入する動作をします。
クラス名を参照することは文法上は定数を参照していることになります。

          class C
          end
          p C    # => C

あるクラスまたはモジュールで定義された定数を外部から参照する
ためには`::'演算子を用います。またObjectクラスで
定義されている定数(トップレベルの定数と言う)を確実に参照する
ためには左辺無しの`::'演算子が使えます。

例:

          module M
            I = 35
            class C
            end
          end
          p M::I   #=> 35
          p M::C   #=> M::C
          p ::M    #=> M

          M::NewConst = 777   # => 777

====[a:prio] 定数参照の優先順位

親クラスとネストの外側のクラスで同名の定数が定義されているとネストの外
側の定数の方を先に参照します。つまり、定数参照時の定数の探索順序は、最
初にネスト関係を外側に向かって探索し、次に継承関係を上位に向かって探索
します。

例:

        class Foo
          CONST = 'Foo'
        end

        class Bar
          CONST = 'Bar'
          class Baz < Foo
            p CONST             # => "Bar"      外側の定数
            # この場合、親クラスの定数は明示的に指定しなければ見えない
            p Foo::CONST        # => "Foo"
          end
        end

トップレベルの定数定義はネストの外側とはみなされません。したがってトッ
プレベルの定数は、継承関係を探索した結果で参照されるので優先順位は低い
と言えます。

例:

        class Foo
          CONST = 'Foo'
        end

        CONST = 'Object'

        class Bar < Foo
          p CONST               # => "Foo"
        end

        # 以下のように明示的にネストしていれば規則通り Object の定数
        # (ネストの外側)が先に探索される
        class Object
          class Bar < Foo
            p CONST             # => "Object"
          end
        end

上位のクラス(クラスの継承関係上、およびネストの関係上の上位クラス)の定
数と同名の定数(下の例で CONST) に代入を行うと、上位の定数への代入では
なく、そのクラスの定数の定義になります。

例:

        class Foo
          CONST = 'Foo'
        end
        class Bar < Foo
          p CONST               # => "Foo"
          CONST = 'Bar'         # Bar の定数 CONST を*定義*
          p CONST               # => "Bar"  (Foo::CONST は隠蔽される)
          p Foo::CONST          # => "Foo"  (:: 演算子で明示すれば見える)
        end
