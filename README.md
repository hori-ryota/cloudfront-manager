# CloudFront Manager

ポチポチ運用が辛いのでawscliを用いたjson管理にしました。

未熟者shell芸なのでレビュー大歓迎です。

コマンドによってjsonのプロパティ順が違うようなので、作業後は `fetchall.sh` でお掃除することを推奨。

*CloudFrontの設定は失敗するとサービスに致命傷をあたえますが、使用は自己責任でお願いします。*

## 下準備

### 依存ツール

* awscli
* jq

cloudfrontコマンドはpreview版なので有効にする
```sh
$ aws configure set preview.cloudfront true
```

## （基礎知識）主要なawsコマンド

### distribution一覧取得
```sh
$ aws cloudfront list-distributions
```

### distribution個別取得
```sh
$ aws cloudfront get-distribution --id ${distributionId}
```

### distribution更新
```sh
$ aws cloudfront update-distribution --cli-input-json file://${jsonFileName}
```
updateの対象distributionIdはjson内に記述されているのでコマンドで指定はしない

### distribution作成
```sh
$ aws cloudfront create-distribution --cli-input-json file://${jsonFileName}
```

## ディレクトリ構成
```
backup/ # 更新時に旧jsonを退避 # gitignore対象
draft/  # 作成用の下書き置き場 # gitignore対象
json/   # cloudfrontから取得したjson置き場
```
backupディレクトリはdiffを取りやすくするため配置。git管理なので本来は不要ですが、実行時の保険として。

作成はマネジメントコンソールでポチって作るか、後述のコマンドで既存からコピーするのがいいかと思います。

更新はjsonディレクトリ内のファイルを更新してcloudfrontに反映、返ってきたresultでjsonを上書きします。

jsonディレクトリをGitHubにpushすると構成が見えてしまうので、必要に応じてgitignoreしてください（pull-requestでレビューできなくなりますが）。

## スクリプト

vim の quickrun で叩きやすくするため、dirname などでのパス解決はしていないです。 `cloudfront-manager/` ディレクトリ直下で実行してください。

### [fetchall.sh](fetchall.sh)

初期化用。cloudfrontからEnabled状態のdistributionsを取ってきてjsonディレクトリに反映。

削除済みdistributionのjson削除は行わないので、削除も必要ならjsonディレクトリを削除後に実行してください。

### [update.sh](update.sh)

```sh
$ ./update.sh ${targetCName}
```

更新用。`get-distribution` のjsonと `update-distribution` の形式は若干違うので、`jq` コマンドで整形したものを入力へ。

結果を元にjsonディレクトリ内の該当jsonを上書きします。

### [createDraft.sh](createDraft.sh)

```sh
$ ./createDraft.sh ${targetName} [${srcJsonFile}]
```

新規作成用に下書きを `draft/` 下に作成。 `srcJsonFile` を指定すればコピーしてcreate用Jsonに整形。指定がなければ skeleton 作成。

CallerReferenceの値は`date +%s` コマンドでタイムスタンプを使用していますが、distribution間でuniqueにする必要があるようなので必要に応じて調整。

### [create.sh](create.sh)

```sh
$ ./create.sh ${targetName}
```

`draft/` 下の下書きから新規作成。結果をjsonディレクトリ内に保存。

Locationプロパティは邪魔なので削除。

## TODO

* distributionId管理だと視認性が悪いのでaliasをつけたい。
    * cnameがわかりやすいけど複数cnameを使用するときに困るので悩み中。
    * tag機能もあるけどawscli経由だと情報が取得できていなさそうなので様子見。
