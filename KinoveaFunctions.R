# Usage of this script in Japanese
#
# Please change your default text encoding to "UTF-8" on the Rstudio at first following bellow.
# Rstudio [Tools] > [Global Options] > [Code] > [Saving] > [Default text encoding] and change "ask" to "UTF-8"

# sys.source("Kinovea.functions.R")で読み込むと他のライブラリーと同じように使える
#
# ---
# #サンプル
# sys.source("Kinovea.functions.R")
# Kva.import(file) #kvaファイルの読み込み
# ---


#------ KinoveaのKVAファイル処理関数 ------

###ファイルの読み込み###

Kva.import=
  function(file){
    # ファイルの読み込み
    scan(file, what = character(), sep = "\n", blank.lines.skip = F,encoding = "UTF-8") 
  }



###キーフレームのテキストのマイニング###

Kva.Keyframe.text=
  function(file){
    # ファイルの読み込み
    tempfile=Kva.import(file)
    #tempfile=Kva.import("D:/kasago/Kasago_video/1-12_1ch.kva")
    # キーフレームの行検索
    keyframes=tempfile[c(grep("<Keyframe ",tempfile)+2)]
    #keyframes
    # キーフレーム名前の行検索
    keyframeName=tempfile[c(grep("<Keyframe ",tempfile)+5)]
    #keyframeName
    
    #キーフレームの抜き出し
    #とりあえずファンクションを作る
    LineMinning=function(tag,line)
    {
      paste0("<",tag,">")
      p1=regexpr(paste0("<",tag,">"),line)
      p2=regexpr(paste0("</",tag,">"),line)
      substring(line, p1+attr(p1,which = "match.length"),p2-1)
    }
    
    #フレーム番号を抜き出す
    Keyframes_n=as.numeric(LineMinning("Title",keyframes))
    #Keyframes_n
    
    #キーフレームの抜き出し
    Keyframes_c=LineMinning("Text",keyframeName)
    #Keyframes_c
    
    #データフレーム化(#フレーム番号と記述内容の一覧表)
    df=data.frame("frames"=Keyframes_n,"contents"=Keyframes_c)
    
    return(df)
  }



###座標の抽出###

Kva.coordinates=
  function(file){
      # ファイル読み込み
      tempfile=Kva.import(file)
      # TrackPointが始まる行の検索
      TrackframesS=c(grep("<TrackPointList",tempfile)+1)
      TrackframesS
      
      # TrackPointが終わる行の検索
      TrackframesE=c(grep("</TrackPointList",tempfile)-1)
      TrackframesE
      
      #座標名を検索
      CoordName=tempfile[c(grep("<MainLabel Text=",tempfile))]
      CoordName
      
      i=1
      pl=c()
      #pt0=c()
      name=c("frame")
      for(i in c(1:length(TrackframesS))){
        # TrackPointの行を抽出
        coord=tempfile[TrackframesS[i]:TrackframesE[i]]
        
        px=c()
        py=c()
        pt=c()
        
        for(j in c(1:length(coord))){
          # ｘ座標を抽出
          p1=regexpr("<TrackPoint UserX=\"",coord[j])
          p2=regexpr("\" UserXInvariant",coord[j])
          px=c(px,as.numeric(substring(coord[j], p1+attr(p1,which = "match.length"),p2-1)))
          
          # y座標を抽出
          p3=regexpr("\" UserY=\"",coord[j])
          p4=regexpr("\" UserYInvariant",coord[j])
          py=c(py,as.numeric(substring(coord[j], p3+attr(p3,which = "match.length"),p4-1)))
          
          # 時間を抽出
          p6=regexpr("UserTime=\"",coord[j])
          p7=regexpr("\">",coord[j])
          pt=c(pt,as.numeric(substring(coord[j], p6+attr(p6,which = "match.length"),p7-1)))
        }
        
        #pxなどの変数に動的に名前を付ける
        assign(sprintf("px%d",i),get("px"))
        assign(sprintf("py%d",i),get("py"))
        assign(sprintf("pt%d",i),get("pt"))
        
        #座標名を抽出
        n1=regexpr("<MainLabel Text=\"",CoordName[i])
        n2=regexpr("\">",CoordName[i])
        n3=substring(CoordName[i], n1+attr(n1,which = "match.length"),n2-1)
        name=c(name,paste0(n3,".x"),paste0(n3,".y"))
        
        #各データのフレーム数を測定
        pl=c(pl,length(eval(parse(text=sprintf("px%d",i)))))
        
        #最も長いフレームデータを取得
        if(i==1){
          ptf=pt1
        }else{
          if(length(ptf)<length(eval(parse(text=sprintf("pt%d",i))))){
            ptf=eval(parse(text=sprintf("pt%d",i)))
          }
        }
        
        
      }
      
      #フレーム数が短かったら補う
      # if(length(pt)!=max(pl)){
      #   pt=c(pt,c((max(pt)+1):max(pl)))
      # }
      
      #短いベクトルにNAを補完する(座標値)
      for(i in c(1:length(TrackframesS))){
        if(length(eval(parse(text=sprintf("px%d",i))))!=max(pl)){
          assign(sprintf("px%d",i),c(eval(parse(text=sprintf("px%d",i))),rep(NA,max(pl)-length(eval(parse(text=sprintf("px%d",i)))))))
          assign(sprintf("py%d",i),c(eval(parse(text=sprintf("py%d",i))),rep(NA,max(pl)-length(eval(parse(text=sprintf("py%d",i)))))))
        }
      }
      
      #座標のデータフレーム作成
      df=data.frame(ptf)
      for(i in c(1:length(TrackframesS))){
        df=cbind(df,data.frame(eval(parse(text=sprintf("px%d",i))),eval(parse(text=sprintf("py%d",i)))))
      }
      colnames(df)=name
      df
      
    }