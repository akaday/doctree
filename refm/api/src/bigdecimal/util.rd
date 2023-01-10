
#@since 2.6.0
String、Integer、Float、Rational, NilClass オブジェクトを
#@else
String、Integer、Float、Rational オブジェクトを
#@end
BigDecimal オブジェクトに変換する機能を提供します。

 * [[m:String#to_d]]
 * [[m:Integer#to_d]]
 * [[m:Float#to_d]]
 * [[m:Rational#to_d]]
#@since 2.6.0
 * [[m:NilClass#to_d]]
#@end


これらのメソッドを使うには 'bigdecimal/util' を require する必要があります。

なお、Ruby 2.6.0 以降では、'bigdecimal/util' を require すると、
'bigdecimal' 本体も require されます。

= reopen Float

== Instance Methods

--- to_d -> BigDecimal
--- to_d(prec) -> BigDecimal

自身を [[c:BigDecimal]] に変換します。

@param prec 計算結果の精度。省略した場合は [[m:Float::DIG]] + 1 です。

@return [[c:BigDecimal]] に変換したオブジェクト

#@samplecode
require 'bigdecimal'
require 'bigdecimal/util'

p 1.0.to_d       # => 0.1e1
p (1.0 / 0).to_d # => Infinity

p (1.0 / 3).to_d / (2.0 / 3).to_d  # => 0.5e0
p ((1.0 / 3) / (2.0 / 3)).to_d     # => 0.5e0
#@end

@raise ArgumentError prec に負の数を指定した場合に発生します。

= reopen String

== Instance Methods

--- to_d -> BigDecimal

自身を [[c:BigDecimal]] に変換します。BigDecimal(self) と同じです。

@return [[c:BigDecimal]] に変換したオブジェクト

= reopen BigDecimal

== Instance Methods

--- to_digits -> String

自身を "1234.567" のような十進数の形式にフォーマットした文字列に変換し
ます。

@return 十進数の形式にフォーマットした文字列

注意:

このメソッドは非推奨です。[[m:BigDecimal#to_s]]("F") を使用してください。


--- to_d -> BigDecimal

自身を返します。

@return [[c:BigDecimal]] オブジェクト

= reopen Rational

== Instance Methods

--- to_d(nFig)     -> BigDecimal

自身を [[c:BigDecimal]] に変換します。

nFig 桁まで計算を行います。

@param nFig 計算を行う桁数

@return [[c:BigDecimal]] に変換したオブジェクト

@raise ArgumentError nFig に 0 以下を指定した場合に発生します。

#@samplecode
require "bigdecimal"
require "bigdecimal/util"
p Rational(1, 3).to_d(3)  # => 0.333e0
p Rational(1, 3).to_d(10) # => 0.3333333333e0
#@end

= reopen Integer

== Instance Methods

--- to_d -> BigDecimal

自身を [[c:BigDecimal]] に変換します。BigDecimal(self) と同じです。

@return [[c:BigDecimal]] に変換したオブジェクト

#@since 2.6.0

= reopen NilClass

== Instance Methods

--- to_d -> BigDecimal

[[c:BigDecimal]] オブジェクトの 0.0 を返します。

Ruby 2.6 で追加されたメソッドです。

#@samplecode
require "bigdecimal"
require "bigdecimal/util"

p nil.to_d  # => 0.0
#@end
#@end
