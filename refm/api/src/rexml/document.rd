DOM スタイルの XML パーサ。

[[m:REXML::Document.new]] で XML 文書から DOM ツリーを
構築し、ツリーのノードの各メソッドで文書の内容にアクセスします。

以下のプログラムではブックマークの XML からデータを取り出します。

#@samplecode
require 'rexml/document'
require 'pp'

Bookmark = Struct.new(:href, :title, :desc)

doc = REXML::Document.new(<<XML)
<?xml version="1.0" encoding="UTF-8" ?>
<xbel version="1.0">
  <bookmark href="http://www.ruby-lang.org/ja/">
    <title>オブジェクト指向スクリプト言語 Ruby</title>
    <desc>Rubyの公式サイト</desc>
  </bookmark>
  <bookmark href="http://rurema.clear-code.com/">
    <title>最速Rubyリファレンスマニュアル検索！ | るりまサーチ</title>
    <desc>Rubyリファレンスマニュアルを全文検索できる。
とても便利。
    </desc>
  </bookmark>
  <bookmark href="https://github.com/rurema/bitclust">
    <title>rurema/bitclust · GitHub</title>
  </bookmark>
  <bookmark href="https://rubygems.org/gems/bitclust-core" />
</xbel>
XML

bookmarks = REXML::XPath.match(doc, "/xbel/bookmark").map do |bookmark|
  href = bookmark.attribute("href").value
  title_element =  bookmark.elements["title"]
  title = title_element ? title_element.text : nil
  desc_element = bookmark.elements["desc"]
  desc = desc_element ? desc_element.text : nil
  Bookmark.new(href, title, desc)
end
pp bookmarks
# >> [#<struct Bookmark
# >>   href="http://www.ruby-lang.org/ja/",
# >>   title="オブジェクト指向スクリプト言語 Ruby",
# >>   desc="Rubyの公式サイト">,
# >>  #<struct Bookmark
# >>   href="http://rurema.clear-code.com/",
# >>   title="最速Rubyリファレンスマニュアル検索！ | るりまサーチ",
# >>   desc="Rubyリファレンスマニュアルを全文検索できる。\nとても便利。\n    ">,
# >>  #<struct Bookmark
# >>   href="https://github.com/rurema/bitclust",
# >>   title="rurema/bitclust · GitHub",
# >>   desc=nil>,
# >>  #<struct Bookmark
# >>   href="https://rubygems.org/gems/bitclust-core",
# >>   title=nil,
# >>   desc=nil>]
#@end

= class REXML::Document < REXML::Element

XMLの完全な文書(ドキュメント)を表すクラス。

XML処理命令(Processing Instruction, PI)、
DTD(文書型定義、Document Type Definition)、
などを含んでいます。
ドキュメントは直下の子ノードをただ一つ持っています(rootと呼び、
[[m:REXML::Document#root]] でアクセスできます)。
2つ目の要素を([[m:REXML::Element#add_element]]などで)追加しようとすると
例外([[c:RuntimeError]])が発生します。

== Class Methods

--- new(source = nil, context = {}) -> REXML::Document
Document オブジェクトを生成します。

source には [[c:String]]、[[c:IO]]、[[c:REXML::Document]] のいずかが
指定できます。 REXML::Document を指定すると
コンテキストと要素、属性が複製されます。
文字列の場合はそれを XML と見なしてパースします。
IOの場合は、XML文書を読み出してパースします。

context で「コンテキスト」を指定します。テキストノードの空白や
特殊文字の取り扱いを [[c:Hash]] で指定します。
#@include(context)

@param source XML文書(文字列, IO)もしくは REXML::Document オブジェクト
@param context コンテキスト
@raise REXML::ParseException XML文書のパースに失敗した場合に発生します
@raise REXML::UndefinedNamespaceException XML文書のパース中に、定義されていない名前空間
       が現れた場合に発生します

--- parse_stream(source, listener) -> ()
XML文書を source から読み込み、パースした結果を
listener にコールバックで伝えます。

このメソッドは
  Parsers::StreamParser.new( source, listener ).parse
と同じ挙動をします。

コールバックの詳しい仕組みなどについては [[c:REXML::Parsers::StreamParser]]
および [[c:REXML::StreamListener]] を参照してください。

@param source 入力(文字列、IO、IO互換オブジェクト(StringIOなど))
@param listener コールバックオブジェクト

--- entity_expansion_limit -> Integer
実体参照の展開回数の上限を返します。

XML 文書([[c:REXML::Document]])ごとの展開回数がこの値を越えると
例外を発生させ、処理を中断します。

実体参照の展開処理を使った DoS 攻撃に対抗するための
仕組みです。

デフォルトは 10000 です。

このメソッドは Ruby 2.1 から deprecated になりました。
[[m:REXML::Security.entity_expansion_limit]] を使ってください。

@see [[m:REXML::Document.entity_expansion_limit=]]

--- entity_expansion_limit=(val)
実体参照の展開回数の上限を指定します。

XML 文書([[c:REXML::Document]])ごとの展開回数がこの値を越えると
例外を発生させ、処理を中断します。

デフォルトは 10000 です。

このメソッドは Ruby 2.1 から deprecated になりました。
[[m:REXML::Security.entity_expansion_limit=]] を使ってください。

@param val 設定する上限値(整数)
@see [[m:REXML::Document.entity_expansion_limit]]

#@since 1.9.3

--- entity_expansion_text_limit -> Integer
実体参照の展開による文字列の増分(テキストのバイト数)の
最大値を指定します。

展開によって増分値がこの値を越えると
例外を発生させ、処理を中断します。

実体参照の展開処理を使った DoS 攻撃に対抗するための
仕組みです。

デフォルトは 10240 (byte) です。

このメソッドは Ruby 2.1 から deprecated になりました。
[[m:REXML::Security.entity_expansion_text_limit]] を使ってください。

@see [[m:REXML::Document.entity_expansion_text_limit=]],
     [[url:http://www.ruby-lang.org/ja/news/2013/02/22/rexml-dos-2013-02-22/]]



--- entity_expansion_text_limit=(val)
実体参照の展開による文字列の増分(テキストのバイト数)の
最大値を指定します。

展開によって増分値がこの値を越えると
例外を発生させ、処理を中断します。

実体参照の展開処理を使った DoS 攻撃に対抗するための
仕組みです。

デフォルトは 10240 (byte) です。

このメソッドは Ruby 2.1 から deprecated になりました。
[[m:REXML::Security.entity_expansion_text_limit=]] を使ってください。

@see [[m:REXML::Document.entity_expansion_text_limit]]
     [[url:http://www.ruby-lang.org/ja/news/2013/02/22/rexml-dos-2013-02-22/]]

#@end

== Instance Methods

--- node_type -> Symbol
シンボル :document を返します。

--- clone -> REXML::Document
self を複製します。

[[m:REXML::Document.new]](self) と同じです。

--- expanded_name -> String
--- name -> String

""(空文字列)を返します。

XMLの仕様上、このオブジェクトはexpanded name名前を持ちえません。

--- add(child) -> ()
--- <<(child) -> ()
子ノードを追加します。

追加できるものは
  * XML宣言([[c:REXML::XMLDecl]])
  * DTD([[c:REXML::DocType]])
  * ルート要素
のいずれかです。

#@# REXML::Element#add_element と同じ、ただしルート要素が2つになると例外を発生させる
#@#
#@# --- add_element(arg = nil, arg2 = nil)
#@# #@todo
#@#

--- root -> REXML::Element | nil
文書のルート要素を返します。

文書がルート要素を持たない場合は nil を返します。

--- doctype -> REXML::DocType | nil
文書の DTD を返します。

文書が DTD を持たない場合は nil を返します。

--- xml_decl -> REXML::XMLDecl | nil
文書の XML 宣言を返します。

文書が XML 宣言を持たない場合は nil を返します。

--- version -> String
XML 宣言に含まれている XML 文書のバージョンを返します。

文書が XML 宣言を持たない場合はデフォルトの値
([[m:REXML::XMLDecl.default]]で宣言されているもの)を返します。

#@samplecode
require 'rexml/document'
doc = REXML::Document.new(<<EOS)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<e />
EOS
doc.version # => "1.0"
#@end

--- encoding -> String
XML 宣言に含まれている XML 文書のエンコーディングを返します。

文書が XML 宣言を持たない場合はデフォルトの値
([[m:REXML::XMLDecl.default]]で宣言されているもの)を返します。

#@samplecode
require 'rexml/document'
doc = REXML::Document.new(<<EOS)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<e />
EOS
doc.encoding # => "UTF-8"
#@end

--- stand_alone? -> String
XML 宣言の standalone の値を文字列で返します。

#@samplecode
require 'rexml/document'
doc = REXML::Document.new(<<EOS)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<e />
EOS
doc.stand_alone? # => "yes"
#@end

#@until 2.0.0
--- write(output = $stdout, indent = -1, transitive = false, ie_hack = false) -> ()
#@else
--- write(output = $stdout, indent = -1, transitive = false, ie_hack = false, encoding=nil) -> ()
--- write(output: $stdout, indent: -1, transitive: false, ie_hack: false, encoding: nil) -> ()
#@end

output に XML 文書を出力します。

XML宣言、DTD、処理命令を(もしあるならば)含む文書を出力します。

注意すべき点として、
元の XML 文書が XML宣言を含んでいなくとも
出力される XML はデフォルトの XML 宣言を含んでいるべきであるが、
REXML は明示しない限り(つまりXML宣言を [[m:REXML::Document#add]] で
追加しない限り)
それをしない、ということである。XML-RPCのような利用法では
ネットワークバンドを少しでも節約する必要があるためである。

#@since 2.0.0
2.0.0以降ではキーワード引数による引数指定が可能です。
#@end

@param output 出力先([[c:IO]] のように << で書き込めるオブジェクト)
@param indent インデントのスペースの数(-1 だとインデントしない)
@param transitive XMLではインデントのスペースでDOMが変化してしまう場合がある。
       これに真を渡すと、XMLのDOMに余計な要素が加わらないように
       空白の出力を適当に抑制するようになる
@param ie_hack IEはバージョンによってはXMLをちゃんと解釈できないので、
       それに対応したXMLを出力するかどうかを真偽値で指定する

== Constants

--- DECLARATION -> REXML::XMLDecl
この定数は deprecated です。[[m:REXML::XMLDecl.default]] を
代わりに使ってください。

デフォルトとして使えるXML宣言オブジェクト。


#@include(attlistdecl.rd)
#@include(attribute.rd)
#@include(cdata.rd)
#@include(child.rd)
#@include(comment.rd)
#@include(doctype.rd)
#@include(element.rd)
#@include(encoding.rd)
#@include(entity.rd)
#@include(formatters/default.rd)
#@include(formatters/pretty.rd)
#@include(formatters/transitive.rd)
#@include(instruction.rd)
#@include(namespace.rd)
#@include(node.rd)
#@include(parent.rd)
#@include(parsers/baseparser.rd)
#@include(parsers/treeparser.rd)
#@include(security.rd)
#@include(text.rd)
#@include(xmldecl.rd)
#@include(xpath.rd)

#@# internal files
#@include(functions.rd)
#@include(output.rd)
#@include(xmltokens.rd)
#@include(parsers/xpathparser.rd)
#@include(source.rd)
