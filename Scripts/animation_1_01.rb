#==============================================================================
# ■ animation 1.01
#------------------------------------------------------------------------------
# 　ピクチャを扱うクラスです。Game_Pictureに加筆を行いました。
# 　ツクールのFPS 60FPS
# by 3dpose
#==============================================================================

class Game_Picture
  
  #--------------------------------------------------------------------------
  # ● 定数（使用効果）
  #--------------------------------------------------------------------------
  ANIM_FPS     = 3                         # 3.75がMMDの1フレーム相当
                                           # 60/数値 FPSで表示されます
                                           # 30FPS にしたい場合は2にしてください
  ANIM_1ST_NUMBER = 1                      # 連番の最初の数。0か1。
  ANIM_EXT = ".png"                        # 使用するファイルの拡張子
  
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :animateNo                   # アニメーション読み込みフレーム
  
  #--------------------------------------------------------------------------
  # ● 基本変数の初期化 by 3dpose（加筆）
  #--------------------------------------------------------------------------
  def init_basic
    @name = ""
    @origin = @x = @y = @max_frames = 0
    @animateNo = @afn = ANIM_1ST_NUMBER
    @zoom_x = @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
    @filename = ""
    #@max_frames = 0
    @await = ANIM_FPS                          # 一コマのウェイト
  end
  #--------------------------------------------------------------------------
  # ● ピクチャの消去 by 3dpose（加筆）
  #--------------------------------------------------------------------------
  def erase
    @name = ""
    @max_frames = 0
    @await = ANIM_FPS                          # 一コマのウェイト
  end
  #--------------------------------------------------------------------------
  # ● アニメーション by 3dpose
  #--------------------------------------------------------------------------
  def animation(name , size , x , y)
    @filename = name
    c_max_frame(size)
    @x = x
    @y = y
    @animateNo = @afn = ANIM_1ST_NUMBER
    @load_file_name = animation_file_name
    show(@load_file_name, 0, x, y, 100, 100, 255, 0)
  end
  #--------------------------------------------------------------------------
  # ● アニメーションフレーム数 by 3dpose
  #--------------------------------------------------------------------------
  def c_max_frame(value)
    @max_frames = value if ANIM_1ST_NUMBER == 1
    @max_frames = value-1 if ANIM_1ST_NUMBER == 0# ファイル名が0から始まる場合
  end
  #--------------------------------------------------------------------------
  # ● アニメーションファイル名作成
  # 　ファイル名が4桁の場合はnumb44を使用してみてください。
  #--------------------------------------------------------------------------
  def animation_file_name
    @afn += 1
    @animateNo = @afn / @await
    @animateNo = @animateNo.truncate 
    @afn = ANIM_1ST_NUMBER if @animateNo >= @max_frames
    @animateNo = ANIM_1ST_NUMBER if @animateNo >= @max_frames
    if @animateNo < ANIM_1ST_NUMBER
      @animateNo = ANIM_1ST_NUMBER
    end
    numb = numb33(@animateNo)
    #numb = numb44(@animateNo)
    return @filename + numb + ANIM_EXT
  end
  #--------------------------------------------------------------------------
  # ● 3ケタ0字詰め
  #--------------------------------------------------------------------------
  def numb33(numb)
    numb = numb.to_s
    numb = "0" + numb if numb.size == 1
    numb = "0" + numb if numb.size == 2
    return numb
  end
  #--------------------------------------------------------------------------
  # ● 4ケタ0字詰め
  #--------------------------------------------------------------------------
  def numb44(numb)
    numb = numb.to_s
    numb = "0" + numb if numb.size == 1
    numb = "0" + numb if numb.size == 2
    numb = "0" + numb if numb.size == 3
    return numb
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの切り替え
  #--------------------------------------------------------------------------
  def change_animation(name)
    @filename = name
    @afn = ANIM_1ST_NUMBER
  end
  #--------------------------------------------------------------------------
  # ● アニメーションウェイトの変更
  # 1が等倍。数が増えると遅くなります。
  # 60/数値 FPSで表示されます
  #--------------------------------------------------------------------------
  def change_animation_speed(value)
    @await = value
  end
  #--------------------------------------------------------------------------
  # ● ピクチャファイルの存在の確認 by 3dpose
  # 暗号化すると動かないためボツ。
  #--------------------------------------------------------------------------
  def picexist(value)
    FileTest.exist?("Graphics/Pictures/" + value)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 by 3dpose（加筆）
  #--------------------------------------------------------------------------
  def update
    update_move
    update_tone_change
    update_rotate
    update_animate
  end
  #--------------------------------------------------------------------------
  # ● アニメーションアップデート by 3dpose
  #--------------------------------------------------------------------------
  def update_animate
    return if @max_frames == 0
    @name = animation_file_name
  end
end
