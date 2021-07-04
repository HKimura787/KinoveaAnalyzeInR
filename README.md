# KinoveaAnalyzeInR

[Kinovea](https://www.kinovea.org/)で生成された`.kav`ファイルを`R`で解析するためのスクリプトです。一部の関数は`data.table`, `stringr`ライブラリーに依存しています。UTF-8で使用してください。

---

## 1.	スクリプトファイルの読み込み

- Rスクリプトファイルと同じフォルダにある場合

```
source("Kinovea.functions.R")
```


- 違うフォルダにある場合（例）

```
source("C:/User/Downloads/Kinovea.functions.R")
```

---


## 2.	関数の使い方

まず、キノベアで解析してkvaファイル（動画の解析ファイル）を作ってください。

 
 
- `Kva.import("動画の解析ファイル.kva")`

Kinoveaのkvaファイルを読み込みます。



- `Kva.coordinates("動画の解析ファイル.kva")`

Kinoveaでプロットした座標を抽出します。

点を打った順に読み込まれ、ｘ座標はpx1,px2...、ｙ座標はpy1,py2...、のように自動で列名がつきます。


  
- `Kva.coordinate2("動画の解析ファイル", c(“座標名1”,“座標名2”,...))`

`data.table`, `stringr`のインストールが必要です。

Kinoveaでプロットした座標を抽出します。

解析の時に付けた名前を列名（例: x座標, ”座標名1.x”; y座標, ”座標名1.y”）として、そのまま使います。c()の中に座標名のリストをベクトル形式で指定する必要があります。KVAファイルの中の座標名と関数で指定した座標名が一致しない場合はエラーになるかもしれません。


  
- `Kva.Keyframae.text("動画の解析ファイル.kva")`

Kinoveaのテキスト機能でフレームに書き込んだ内容と書き込まれたフレームを表示します。
