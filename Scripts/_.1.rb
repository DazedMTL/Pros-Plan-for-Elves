#==============================================================================
#                        「ピクチャメニュー」(ACE) ver1.2
#   製作者：奈々（なな）
#   へぷたなすくろーる http://heptanas.mamagoto.com/
#
#   ◇使用規約
#   使用される場合はスクリプト作成者として「奈々」を明記して下さい。
#   このスクリプトを改変したり、改変したものを配布するなどは自由ですが
#   その場合も元のスクリプトの作成者として名前は載せて下さい。
#   その他、詳しい利用規約はブログを参照して下さい。
#
#------------------------------------------------------------------------------
#
#   メニュー画面のレイアウトを変更するスクリプトです。
#   コマンドが上、ステータスが下に配置され、現在地も表示されます。
#   そして中央に任意のピクチャを表示することができます。
#   
#   スクリプトの設定により、レイアウトやデザインを変更できます。
#   またイベントコマンドでピクチャを設定することで
#   メニュー中央に地図や立ち絵を表示させる
#   ゲームの進行によって背景が変化させるなど
#   凝ったメニュー画面を作ることが出来ます。
#   
#   ◇ゲーム中での設定方法
#   イベントコマンドの「スクリプト」に書く
#   
#   「set_npm(番号, "ファイル名", x座標, y座標, 不透明度)」
#   pictureフォルダのファイル名を指定、番号は1～8
#   x座標、y座標、不透明度は省略可能で、全て0が代入される。
#   
#   「clear_npm(番号)」
#   設定したピクチャを削除する。番号を0にすると全て消去。
#   
#   「set_menu_background("ファイル名")」
#   systemフォルダのファイル名を指定して背景を変更する。
#   初期設定と同じく""でデフォルトと同じマップ画面背景となる。
#   
#   「clear_menu_background」
#   背景を初期化する。（初期設定に戻すだけ）
#
#==============================================================================
module Nana_PictureMenu

  # ◇メニュー画面の背景の初期設定
  #   systemフォルダのファイル名を指定、""でデフォルトと同じマップ画面背景。
  
  BACKGROUND = ""
  
  
  # ◇ウィンドウ枠の表示設定
  #   trueで表示、falseで非表示に
  
  B_COMMAND = true  #コマンド
  B_GOLD = true     #所持金
  B_MAPNAME = false  #マップ名
  B_STATUS = false   #ステータス　falseにすることで枠消去
  
  # ◇マップ名ウィンドウの横幅
  
  MAPNAME_WIDTH = 160

  # ◇パーティ５人以上の時にステータスウィンドウを２行にするか
  STATUS_DOUBLE = true
  
  
  # ◇メニューの項目表示数
  #   （表示されない分はスクロール）
  
  C_YOKO = 5  #横
  C_TATE = 2  #縦
  
  # ◇メニューの項目設定
  #   trueで表示、falseで非表示に
  
  C_1 = true  #アイテム
  C_2 = true  #スキル
  C_3 = true  #装備
  C_4 = true  #ステータス
  C_5 = false  #並び替え
  C_6 = true  #セーブ
  C_7 = true  #ゲーム終了
  
end


#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● メニュー背景設定
  #--------------------------------------------------------------------------
  def set_menu_background(filename)
    $game_system.menu_background = filename
    p $game_system.menu_background
  end
  #--------------------------------------------------------------------------
  # ● メニュー背景初期化
  #--------------------------------------------------------------------------
  def clear_menu_background
    $game_system.menu_background = nil
  end
  #--------------------------------------------------------------------------
  # ● メニューピクチャ設定
  #--------------------------------------------------------------------------
  def set_npm(number, filename, x = 0, y = 0, opacity = 255)
    case number
    when 1
      $game_system.menu_picture1 = [filename, x, y, opacity]
    when 2
      $game_system.menu_picture2 = [filename, x, y, opacity]
    when 3
      $game_system.menu_picture3 = [filename, x, y, opacity]
    when 4
      $game_system.menu_picture4 = [filename, x, y, opacity]
    when 5
      $game_system.menu_picture5 = [filename, x, y, opacity]
    when 6
      $game_system.menu_picture6 = [filename, x, y, opacity]
    when 7
      $game_system.menu_picture7 = [filename, x, y, opacity]
    when 8
      $game_system.menu_picture8 = [filename, x, y, opacity]
    end
  end
  #--------------------------------------------------------------------------
  # ● メニューピクチャ削除
  #--------------------------------------------------------------------------
  def clear_npm(number)
    case number
    when 1
      $game_system.menu_picture1 = nil
    when 2
      $game_system.menu_picture2 = nil
    when 3
      $game_system.menu_picture3 = nil
    when 4
      $game_system.menu_picture4 = nil
    when 5
      $game_system.menu_picture5 = nil
    when 6
      $game_system.menu_picture6 = nil
    when 7
      $game_system.menu_picture7 = nil
    when 8
      $game_system.menu_picture8 = nil
    when 0
      $game_system.menu_picture1 = nil
      $game_system.menu_picture2 = nil
      $game_system.menu_picture3 = nil
      $game_system.menu_picture4 = nil
      $game_system.menu_picture5 = nil
      $game_system.menu_picture6 = nil
      $game_system.menu_picture7 = nil
      $game_system.menu_picture8 = nil
    end
  end
end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :menu_background          # メニュー背景
  attr_accessor :menu_picture1            # メニューピクチャ１
  attr_accessor :menu_picture1_x          # メニューピクチャ１のX座標
  attr_accessor :menu_picture1_y          # メニューピクチャ１のX座標
  attr_accessor :menu_picture2            # メニューピクチャ２
  attr_accessor :menu_picture2_x          # メニューピクチャ２のX座標
  attr_accessor :menu_picture2_y          # メニューピクチャ２のX座標
  attr_accessor :menu_picture3            # メニューピクチャ３
  attr_accessor :menu_picture3_x          # メニューピクチャ３のX座標
  attr_accessor :menu_picture3_y          # メニューピクチャ３のX座標
  attr_accessor :menu_picture4            # メニューピクチャ４
  attr_accessor :menu_picture4_x          # メニューピクチャ４のX座標
  attr_accessor :menu_picture4_y          # メニューピクチャ４のX座標
  attr_accessor :menu_picture5            # メニューピクチャ５
  attr_accessor :menu_picture5_x          # メニューピクチャ５のX座標
  attr_accessor :menu_picture5_y          # メニューピクチャ５のX座標
  attr_accessor :menu_picture6            # メニューピクチャ６
  attr_accessor :menu_picture6_x          # メニューピクチャ６のX座標
  attr_accessor :menu_picture6_y          # メニューピクチャ６のX座標
  attr_accessor :menu_picture7            # メニューピクチャ７
  attr_accessor :menu_picture7_x          # メニューピクチャ７のX座標
  attr_accessor :menu_picture7_y          # メニューピクチャ７のX座標
  attr_accessor :menu_picture8            # メニューピクチャ８
  attr_accessor :menu_picture8_x          # メニューピクチャ８のX座標
  attr_accessor :menu_picture8_y          # メニューピクチャ８のX座標
end

#==============================================================================
# ■ Scene_MenuBase
#------------------------------------------------------------------------------
# 　メニュー画面系の基本処理を行うクラスです。
#==============================================================================

class Scene_MenuBase < Scene_Base
  #--------------------------------------------------------------------------
  # ● 背景の作成
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    if $game_system.menu_background
      filename = $game_system.menu_background
    else
      filename = Nana_PictureMenu::BACKGROUND
    end
    
    if filename == ""
      @background_sprite.bitmap = SceneManager.background_bitmap
      @background_sprite.color.set(16, 16, 16, 128)
    else
      @background_sprite.bitmap = Cache.system(filename)
    end
  end
end

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
    create_gold_window
    create_map_window
    create_status_window
    create_picture_sprite
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_picture_sprite
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item)) if Nana_PictureMenu::C_1 == true
    @command_window.set_handler(:skill,     method(:command_personal)) if Nana_PictureMenu::C_2 == true
    @command_window.set_handler(:equip,     method(:command_personal)) if Nana_PictureMenu::C_3 == true
    @command_window.set_handler(:status,    method(:command_personal)) if Nana_PictureMenu::C_4 == true
    @command_window.set_handler(:formation, method(:command_formation)) if Nana_PictureMenu::C_5 == true
    @command_window.set_handler(:save,      method(:command_save)) if Nana_PictureMenu::C_6 == true
    @command_window.set_handler(:game_end,  method(:command_game_end)) if Nana_PictureMenu::C_7 == true
    @command_window.set_handler(:cancel,    method(:return_scene))
    @command_window.opacity = 0 if Nana_PictureMenu::B_COMMAND == false
  end
  #--------------------------------------------------------------------------
  # ● ゴールドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @command_window.height
    @gold_window.opacity = 0 if Nana_PictureMenu::B_GOLD == false
  end
  #--------------------------------------------------------------------------
  # ● マップ名ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_map_window
    @map_window = Window_MenuMap.new
    @map_window.x = 0
    @map_window.y = @command_window.height
    @map_window.opacity = 0 if Nana_PictureMenu::B_MAPNAME == false
  end
  #--------------------------------------------------------------------------
  # ● ピクチャの作成
  #--------------------------------------------------------------------------
  def create_picture_sprite
    @picture_sprite1 = Sprite.new
    @picture_sprite2 = Sprite.new
    @picture_sprite3 = Sprite.new
    @picture_sprite4 = Sprite.new
    @picture_sprite5 = Sprite.new
    @picture_sprite6 = Sprite.new
    @picture_sprite7 = Sprite.new
    @picture_sprite8 = Sprite.new
    
    if $game_system.menu_picture1
      @picture_sprite1.bitmap = Cache.picture($game_system.menu_picture1[0])
      @picture_sprite1.x = $game_system.menu_picture1[1]
      @picture_sprite1.y = $game_system.menu_picture1[2]
      @picture_sprite1.opacity = $game_system.menu_picture1[3]
    end
    if $game_system.menu_picture2
      @picture_sprite2.bitmap = Cache.picture($game_system.menu_picture2[0])
      @picture_sprite2.x = $game_system.menu_picture2[1]
      @picture_sprite2.y = $game_system.menu_picture2[2]
      @picture_sprite2.opacity = $game_system.menu_picture2[3]
    end
    if $game_system.menu_picture3
      @picture_sprite3.bitmap = Cache.picture($game_system.menu_picture3[0])
      @picture_sprite3.x = $game_system.menu_picture3[1]
      @picture_sprite3.y = $game_system.menu_picture3[2]
      @picture_sprite3.opacity = $game_system.menu_picture3[3]
    end
    if $game_system.menu_picture4
      @picture_sprite4.bitmap = Cache.picture($game_system.menu_picture4[0])
      @picture_sprite4.x = $game_system.menu_picture4[1]
      @picture_sprite4.y = $game_system.menu_picture4[2]
      @picture_sprite4.opacity = $game_system.menu_picture4[3]
    end
    if $game_system.menu_picture5
      @picture_sprite5.bitmap = Cache.picture($game_system.menu_picture5[0])
      @picture_sprite5.x = $game_system.menu_picture5[1]
      @picture_sprite5.y = $game_system.menu_picture5[2]
      @picture_sprite5.opacity = $game_system.menu_picture5[3]
    end
    if $game_system.menu_picture6
      @picture_sprite6.bitmap = Cache.picture($game_system.menu_picture6[0])
      @picture_sprite6.x = $game_system.menu_picture6[1]
      @picture_sprite6.y = $game_system.menu_picture6[2]
      @picture_sprite6.opacity = $game_system.menu_picture6[3]
    end
    if $game_system.menu_picture7
      @picture_sprite7.bitmap = Cache.picture($game_system.menu_picture7[0])
      @picture_sprite7.x = $game_system.menu_picture7[1]
      @picture_sprite7.y = $game_system.menu_picture7[2]
      @picture_sprite7.opacity = $game_system.menu_picture7[3]
    end
    if $game_system.menu_picture8
      @picture_sprite8.bitmap = Cache.picture($game_system.menu_picture8[0])
      @picture_sprite8.x = $game_system.menu_picture8[1]
      @picture_sprite8.y = $game_system.menu_picture8[2]
      @picture_sprite8.opacity = $game_system.menu_picture8[3]
    end
  end
  #--------------------------------------------------------------------------
  # ● ピクチャの解放
  #--------------------------------------------------------------------------
  def dispose_picture_sprite
    @picture_sprite1.dispose
    @picture_sprite2.dispose
    @picture_sprite3.dispose
    @picture_sprite4.dispose
    @picture_sprite5.dispose
    @picture_sprite6.dispose
    @picture_sprite7.dispose
    @picture_sprite8.dispose
  end
end

#==============================================================================
# ■ Window_MenuMap
#------------------------------------------------------------------------------
# 　所持金を表示するウィンドウです。
#==============================================================================

class Window_MenuMap < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return Nana_PictureMenu::MAPNAME_WIDTH
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text(4, 0, contents.width - 8, line_height, value)
  end
  #--------------------------------------------------------------------------
  # ● マップ名の取得
  #--------------------------------------------------------------------------
  def value
    $game_map.display_name
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end
#==============================================================================
# ■ Window_MenuStatus
#------------------------------------------------------------------------------
# 　メニュー画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :pending_index            # 保留位置（並び替え用）
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    self.x = 0
    self.y = Graphics.height - window_height
    @pending_index = -1
    self.opacity = 0 if Nana_PictureMenu::B_STATUS == false
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    416 / (item_max > 4 && Nana_PictureMenu::STATUS_DOUBLE ? 2 : 4)
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    (window_height - standard_padding * 2) / (item_max > 4 && Nana_PictureMenu::STATUS_DOUBLE ? 2 : 1)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_simple_status(actor, rect.x + 2, rect.y + 2)
  end
  #--------------------------------------------------------------------------
  # ● シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    if window_width >= 640
      draw_actor_icons(actor, x + 80, y)
      draw_actor_hp(actor, x, y + line_height * 1)
      draw_actor_mp(actor, x, y + line_height * 2)
    else
      draw_actor_hp(actor, x, y + line_height * 1, 100)
      draw_actor_mp(actor, x, y + line_height * 2, 100)
    end
  end
end
#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width 
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return Nana_PictureMenu::C_YOKO
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return Nana_PictureMenu::C_TATE
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_commands
    add_formation_command if Nana_PictureMenu::C_5 == true
    add_original_commands
    add_save_command if Nana_PictureMenu::C_6 == true
    add_game_end_command if Nana_PictureMenu::C_7 == true
  end
  #--------------------------------------------------------------------------
  # ● 主要コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_main_commands
    add_command(Vocab::item,   :item,   main_commands_enabled) if Nana_PictureMenu::C_1 == true
    add_command(Vocab::skill,  :skill,  main_commands_enabled) if Nana_PictureMenu::C_2 == true
    add_command(Vocab::equip,  :equip,  main_commands_enabled) if Nana_PictureMenu::C_3 == true
    add_command(Vocab::status, :status, main_commands_enabled) if Nana_PictureMenu::C_4 == true
  end
end
