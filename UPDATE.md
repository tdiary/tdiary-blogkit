# 1.5.2以前のBlogkitからのアップデートについて

新しいBlogkitは、最新のtDiaryからサポートされた「スタイル」に対応しました。この結果、旧Blogkitを使っていた場合には、以下の手順で設定を変更してください:

1. 従来のblogio.rbを削除し、新しいblog_style.rbを同じ場所にコピーします。
2. tdiary.confの「require 'tdiary/blogio'」を削除し、代わりに「@style = 'Blog'」を追加します。

さらに非互換吸収のために、データのコンバートが必要になりました:

3. @data_pathにある*.td2というファイルをすべて見つけてください
4. 見つけたファイルをテキストエディタで開き、すべての「Format: tDiary」を「Format: Blog」に置換します。
5. ファイルを保存後、@data_path/cacheディレクトリにある*.parserファイルと*.rbファイルを削除してください。

もし、上記の方法が実施できないのであれば、以下の方法を代わりに実施してもよいです。

3. blog_style.rbを開いて、以下の行を見つけます。

      # TDiary::DefaultIO::add_style( 'tDiary', self )

4. この行を以下のように書き換えます(「#」を削除するだけ)。

      TDiary::DefaultIO::add_style( 'tDiary', self )

5. ファイルを保存し、@data_path/cacheにある*.parserと*.rbを削除します。

あとの方法は互換性維持のための逃げ手なので、できれば先の方法をお勧めします。
