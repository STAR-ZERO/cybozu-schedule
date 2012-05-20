#cybozu-schedule

## 概要
サイボウズOfficeのスケジュールチェックしてGrowlに通知します

## 必要なもの
Ruby
Growl
growlnotify


## インストール
    $ git clone git://github.com/STAR-ZERO/cybozu-schedule.git
    $ cd cybozu-schedule
    $ bundle install

## 設定
インストールディレクトリのdata/setting.yamlを設定します

 - url: サイボウズのURL（ag.cgiで終わるように）
 - username: サイボウズのログインユーザー名
 - password: サイボウズのパスワード
 - interval: 何分先まで読み込むか
 - sticky: growl通知を画面に留まらせるか(true or false)
 - start_over: スケジュールの開始〜終了時間内も通知するか(true or false)

## Growlに表示させるアイコン
インストールディレクトリのdataディレクトリ内に「icon.jpg」「icon.jpeg」「icon.png」のいずれかがあるとそれをアイコンとしてGrowlに表示します。

## 使い方
    $ ./cybozu_schedule.rb

cron等に設定して定期実行

