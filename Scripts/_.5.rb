#==============================================================================
# ■ ギャルゲーっぽい会話システム12
#   @version 0.97 14/03/22 RGSS3
#   @author さば缶
#------------------------------------------------------------------------------
# ■使い方
#   ギャルゲー風会話ウィンドウを出したい場合、
#   スイッチ133番をONにします。
#
#   画像を用意します。書き方は、
#   actor<アクターID>_<表情ID>_<スタイルID>.png
#   です。
#   例：actor1_1_1.png
#
#   スタイルIDは省略可能です。
#   例：actor1_1.png
#
#   使われる画像は、顔グラフィック＋スタイルIDで決まります。
#   顔グラフィックは、会話イベント作成時に選択します。
#   スタイルIDは変数で設定します。
#   actor1 の スタイルID は変数221で、
#   actor2 の スタイルID は変数222で、
#   actor3 の スタイルID は変数223で(以下続く)
#   ※スタイルIDは服装変化などの時を想定しています。
#   
#==============================================================================
module Saba
  module Gal
    # --------------------設定---------------------
    
    # 各キャラごとに立ち位置を微調整できます。
    # {アクターID=>ずらすピクセル数}
    OFFSET_X = {1=>40, 2=>40, 3=>40, 4=>40, 5=>40, 6=>40, 7=>40, 8=>-40, 9=>40, 10=>-25, 11=>18, 12=>18, 13=>18, 14=>18, 15=>-60, 16=>-60, 17=>40, 18=>-60, 19=>-60, 20=>-40, 21=>-60, 22=>-40, 23=>-40, 24=>40, 25=>-40, 26=>-40, 27=>-40, 28=>-40, 29=>-40, 30=>-40, 31=>-40, 32=>-40, 33=>-40, 34=>-40, 35=>-40, 36=>-40, 37=>-40, 38=>-40, 39=>-40}
    OFFSET_Y = {1=>-30, 2=>-30, 3=>-30, 4=>-30, 5=>-30, 6=>-30, 7=>-30, 8=>-30, 9=>-30, 10=>-30, 11=>-30, 12=>-30, 13=>-30, 14=>-30, 15=>-30, 16=>-30, 17=>-30, 18=>-30, 19=>-30, 20=>-30, 21=>-30, 22=>-30, 23=>-30, 24=>-30, 25=>-30, 26=>-30, 27=>-30, 28=>-30, 29=>-30, 30=>-30, 31=>-30, 32=>-30, 33=>-30, 34=>-30, 35=>-30, 36=>-30, 37=>-30, 38=>-30, 39=>-30}
    # ↑の OFFSET_X の値について、左にキャラを表示する時のみ
    # 座標に -1 をかける場合 true に設定します。
    MIRROR_LEFT_OFFSET_X = false
    
    # フキダシの座標です
    BALLOON_LEFT_X = 320   # X 座標。左に表示される場合
    BALLOON_RIGHT_X = 320  # X 座標。右に表示される場合
    BALLOON_CENTER_X = 320 # X 座標。中央に表示される場合
    BALLOON_Y = 240        # Y 座標
    
    # 名前ウィンドウの横幅。とりあえず4文字入るサイズ
    NAME_WINDOW_WIDTH = 114
    
    # メッセージスキップボタン
    SKIP_BUTTON = Input::CTRL
    
    # メッセージスキップを OFF にするスイッチ
    SKIP_DISABLE_SWITCH = 131
    
    # 名前を表示するスイッチ
    DISPLAY_NAME_SWITCH = 132
    
    # 会話モードにするスイッチ
    MESSAGE_MODE_SWITCH = 133
    
    # フキダシを表示するスイッチ
    DISPLAY_BALLOON_SWITCH = 134
    
    # フキダシをクリアするスイッチ
    CLEAR_BALLOON_SWITCH = 135
    
    # メッセージ音を鳴らすスイッチ
    #PLAY_MESSAGE_SE_SWITCH = 136
    
    # キャラをセンターにもってくるスイッチ
    CENTER_SWITCH = 137
    
    # キャラの顔グラを表示するスイッチ
    SHOW_FACE_SWITCH = 138
    
    # ウィンドウを閉じないスイッチ
    NOT_CLOSE_WINDOW_SWITCH = 139
    
    # キャラを非表示にするスイッチ
    HIDE_CHAR_SWITCH = 140
    
    # フキダシ色を設定する変数
    # ※自動で値が入力されます。
     BALLOON_VARIABLE = 131
    
    # フキダシ位置を設定する変数
    # ※自動で値が入力されます。
     BALLOON_POSITION_VARIABLE = 132
    
    # アクター1のスタイルをあらわす変数。
    # アクター2以降は1ずつずれていきます。
    # ■例
    #  301 の変数に 0 を入れてアクター 1 の表情 0 を表示
    #　→　actor1_1.png が使われる
    #  
    #  301 の変数に 1 を入れてアクター 1 の表情 0 を表示
    #  →  actor1_1_1.png が使われる
    #
    #  302 の変数に 1 を入れてアクター 2 の表情 2 を表示
    #  → actor2_3_1.png が使われる
    ACTOR_STYLE_VARIABLE = 221
    
    # 左に表示させるキャラグラを反転させる場合、true に設定します。
    MIRROR_LEFT = false
    
    # 右に表示させるキャラグラを反転させる場合、true に設定します。
    MIRROR_RIGHT = false
    
    # ウィンドウスキンをキャラごとに変化させない場合、true に設定します。
    # Window1.png と Balloon1.png が使われます。
    USE_SINGLE_WINDOW_SKIN = true
    
    # 会話中のキャラの色調です
    # 赤, 緑, 青, 灰
    ACTIVE_TONE = Tone.new(0, 0,0, 0)
    # 会話していないキャラの色調です (0, 0, 0, 0で変化なしです)
    INACTIVE_TONE = Tone.new(-80, -80, -80, 0)
    
    # キャラ切り替えの色調変化の期間
    TONE_CHANGE_DURATION = 17
    
    # 立ち位置を切り替える期間
    CAHNGE_POSITION_DURATION = 17
    
    # イベントコマンド、「フキダシアイコンの表示」用の位置調整
    OFFSET_EVENT_BALLOON_X = {1=>0, 2=>0, 3=>-30, 6=>-40, 7=>-45, 8=>-40}
    OFFSET_EVENT_BALLOON_Y = {1=>0, 2=>10, 3=>40, 4=>10, 7=>-15, 8=>5}
    
    # ウィンドウ色を切り替えるとき、不透明度を下げた状態で変化させる場合true
    ENBALE_WINDOW_CHANGE_TRANSITION = true
    
    # 顔グラフィック表示用
    FACE_WINDOW_X = 26
    FACE_WINDOW_BOTTOM = 89
    FACE_WINDOW_HEIGHT = 108
    FACE_WINDOW_COLOR = 0     # 顔グラ表示中のウィンドウ色
  end
end


$imported = {} if $imported == nil
$imported["GalGameTalkSystem"] = true


class Scene_Battle
  #--------------------------------------------------------------------------
  # ● イベントの処理(再定義！)
  #--------------------------------------------------------------------------
  alias saba_gal_process_event process_event
  def process_event
    while !scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message unless $game_switches[Saba::Gal::MESSAGE_MODE_SWITCH] # これ
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      BattleManager.judge_win_loss
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
end

class Game_Picture
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :saba_center                   # 中央フラグ
  attr_accessor   :saba_actor_id                 # 
  alias saba_gal_erase erase
  def erase
    saba_gal_erase
    @saba_center = false
    @saba_actor_id = -1
  end
end
  
# ピクチャ表示用
class Game_Interpreter
  include Saba::Gal
  attr_accessor :actor_id
  
  alias saba_gal_clear clear
  def clear
    saba_gal_clear
    @actor_id_list = []
  end
  def pic(name, index, position)
    actor_id = name["actor".length..-1].to_i
    
    $game_variables[Saba::Gal::BALLOON_POSITION_VARIABLE] = position
    x = picture_base_x(position) + offset_x(position, actor_id)
    y = picture_base_y(position) + offset_y(actor_id)
    $game_variables[Saba::Gal::BALLOON_VARIABLE] = actor_id
    return if $game_switches[HIDE_CHAR_SWITCH]
    picture = screen.pictures[position + 10]
    
    last_name = name
    name = name + "_" + (index + 1).to_s
    
    style = $game_variables[ACTOR_STYLE_VARIABLE + actor_id - 1]
    if style > 0
      begin
        Cache.picture(name + "_" + style.to_s)
        name = name + "_" + style.to_s
      rescue
        p "warning:#{name}_#{style}のファイルが見つかりません。#{name} を使います"
      end
    end
    
    begin
      Cache.picture(name)
    rescue
      p "warning:#{name}のファイルが見つかりません.#{last_name}_1を使います"
      name = last_name + "_1"
    end
    
    @actor1_position = nil if @actor1_position == position
    if Saba::Gal::MIRROR_RIGHT && position == 0
      picture.mirror_pic = true
    elsif Saba::Gal::MIRROR_LEFT && position == 2
      picture.mirror_pic = true
    else
      picture.mirror_pic = false
    end
    
    move = move_to_center?(position)
    picture.show(name, 0, x, y, 100, 100, 255, 0)
    picture.saba_actor_id = actor_id
    if @actor_id != actor_id
      picture.start_tone_change(INACTIVE_TONE, 0) 
      deactivate_other_pictures(position)
      activate(picture, position, actor_id)
    end
    if move
      move_to_center
    else
      if appear_from_center?
        appear_from_center 
        if @actor_id != actor_id
          picture.start_tone_change(INACTIVE_TONE, 0)
          activate(picture, position, actor_id)
        end
      end
    end
    
    @actor_id = actor_id
    
    calc_position(position)
    return true
  end
  def move_to_center?(pos)
    return false unless $game_switches[CENTER_SWITCH]
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    
    if pos == 0
      return false if picture1.saba_center
      return true if picture2.name.empty? && ! picture1.name.empty?
    else
      return false if picture2.saba_center
      return true if picture1.name.empty? && ! picture2.name.empty?
    end
    return false
  end
  def calc_position(pos)
    return pos unless $game_switches[CENTER_SWITCH]
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    if pos == 0
      return 1 if picture2.name.empty?
    else
      return 1 if picture1.name.empty?
    end
    restore_position
    return pos
  end
  def restore_position
    return unless $game_switches[CENTER_SWITCH]
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    unless picture1.name.empty?
      actor_id = picture1.saba_actor_id
      x = picture_base_x(0) + offset_x(0, actor_id)
      y = picture_base_y(0) + offset_y(actor_id)
      picture1.move(0, x, y, 100, 100, 255, 0, change_position_duration)
      picture1.saba_center = false
    end
    unless picture2.name.empty?
      actor_id = picture2.saba_actor_id
      x = picture_base_x(2) + offset_x(2, actor_id)
      y = picture_base_y(2) + offset_y(actor_id)
      picture2.move(0, x, y, 100, 100, 255, 0, change_position_duration)
      picture2.saba_center = false
    end
  end
  #--------------------------------------------------------------------------
  # ● ピクチャのオフセット位置のx座標取得
  #--------------------------------------------------------------------------
  def offset_x(position, actor_id)
    n = Saba::Gal::OFFSET_X[actor_id]

    return 0 if n == nil
    if position == 1 && Saba::Gal::MIRROR_LEFT_OFFSET_X
      return -n
    else
      return n
    end
  end
  #--------------------------------------------------------------------------
  # ● ピクチャのオフセット位置のy座標取得
  #--------------------------------------------------------------------------
  def offset_y(actor_id)
    n = Saba::Gal::OFFSET_Y[actor_id]
    return 0 if n == nil
    return n
  end
  #--------------------------------------------------------------------------
  # ● イベントバルーンのオフセット位置のx座標取得
  #--------------------------------------------------------------------------
  def offset_event_balloon_x(position, actor_id)
    n = Saba::Gal::OFFSET_EVENT_BALLOON_X[actor_id]
    return 0 if n == nil
    if position == 1 && Saba::Gal::MIRROR_LEFT_OFFSET_X
      return -n
    else
      return n
    end
  end
  #--------------------------------------------------------------------------
  # ● イベントバルーンのオフセット位置のy座標取得
  #--------------------------------------------------------------------------
  def offset_event_balloon_y(actor_id)
    n = Saba::Gal::OFFSET_EVENT_BALLOON_Y[actor_id]
    return 0 if n == nil
    return n
  end
  #--------------------------------------------------------------------------
  # ● 指定のピクチャを明るく
  #--------------------------------------------------------------------------
  def activate(picture, position, actor_id)
    if Input.press?(Saba::Gal::SKIP_BUTTON)
      picture.start_tone_change(Saba::Gal::ACTIVE_TONE, 1)
    else
      picture.start_tone_change(Saba::Gal::ACTIVE_TONE, 25)
    end
    $game_temp.pic_actors[position] = actor_id
  end
  #--------------------------------------------------------------------------
  # ● 指定のピクチャ以外を暗く
  #--------------------------------------------------------------------------
  def deactivate_other_pictures(position)
    [10, 12].each do |index|
      next if screen.pictures[index].number == 1
      next if index == position + 10
      deactivate(screen.pictures[index])
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定のピクチャを暗く
  #--------------------------------------------------------------------------
  def deactivate(picture)
    unless Input.press?(Saba::Gal::SKIP_BUTTON)
      picture.start_tone_change(Saba::Gal::INACTIVE_TONE, 25)
    end
  end
  def picture_base_x(position)
    case position
    when 2
      return 25
    when 1
      return Graphics.width / 2 - 120
    when 0
      return Graphics.width - 244
    end
  end
  def picture_base_y(position)
    return 30
  end
  def act(position)
    $game_variables[Saba::Gal::BALLOON_VARIABLE] = $game_temp.pic_actors[position]
    if position < 3
      $game_variables[Saba::Gal::BALLOON_POSITION_VARIABLE] = position
    end
    picture = screen.pictures[position + 10]
    deactivate_other_pictures(position)
    if Input.press?(Saba::Gal::SKIP_BUTTON)
      picture.start_tone_change(Saba::Gal::ACTIVE_TONE, 1)
      @wait_count = 0
    else
      picture.start_tone_change(Saba::Gal::ACTIVE_TONE, Saba::Gal::TONE_CHANGE_DURATION)
     @wait_count = 0
    end
  end
  def dis(position)
    picture = screen.pictures[position + 10]
    picture.erase
  end
  def appear_from_center?
    return false unless $game_switches[CENTER_SWITCH]
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    return picture1.name.empty? != picture2.name.empty?
  end
  def appear_from_center
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    center_picture = picture1.name.empty? ? picture2 : picture1
    actor_id = center_picture.saba_actor_id
    x = picture_base_x(1) + offset_x(0, actor_id)
    y = picture_base_y(1) + offset_y(actor_id)
    center_picture.show(center_picture.name, 0, x, y, 100, 100, 255, 0)
    center_picture.saba_center = true
  end
  def move_to_center
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    return if picture1.name.empty? == picture2.name.empty?
    center_picture = picture1.name.empty? ? picture2 : picture1
    actor_id = center_picture.saba_actor_id
    x = picture_base_x(1) + offset_x(0, actor_id)
    y = picture_base_y(1) + offset_y(actor_id)
    center_picture.move(0, x, y, 100, 100, 255, 0, change_position_duration)
    center_picture.saba_center = true
  end
  def center?
    picture1 = screen.pictures[0 + 10]
    picture2 = screen.pictures[2 + 10]
    return picture1.saba_center || picture2.saba_center
  end
  def change_position_duration
    return 0 if Input.press?(Saba::Gal::SKIP_BUTTON)
    return Saba::Gal::CAHNGE_POSITION_DURATION
  end
end

module Saba::GalWindow
  #--------------------------------------------------------------------------
  # ● ギャルゲーウィンドウ作成
  #   ギャルゲーモードの時、ウィンドウを切り替えます。
  #--------------------------------------------------------------------------
  def create_gal_window
    if $game_switches[Saba::Gal::MESSAGE_MODE_SWITCH]
      if ! @message_window.is_a?(Window_MessageGal)
        # ギャルゲーウィンドウにする
        @message_window.dispose
        @message_window = Window_MessageGal.new
      end
    else
      if @message_window.is_a?(Window_MessageGal)
        # 通常ウィンドウに戻す
        @message_window.dispose
        @message_window = Window_Message.new
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ギャルゲーウィンドウのフキダシアイコン作成
  #--------------------------------------------------------------------------
  def create_gal_event_balloon(character)
    dispose_gal_event_balloon
    @saba_balloon_sprite = Sprite_Character.new(@viewport, character)
  end
  #--------------------------------------------------------------------------
  # ● ギャルゲーウィンドウのフキダシアイコン破棄
  #--------------------------------------------------------------------------
  def dispose_gal_event_balloon
    if @saba_balloon_sprite
      @saba_balloon_sprite.dispose
      @saba_balloon_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● ギャルゲーウィンドウのフキダシアイコン更新
  #--------------------------------------------------------------------------
  def update_gal_event_balloon
    if @saba_balloon_sprite
      if @saba_balloon_sprite.character.balloon_id == 0 || Input.press?(Saba::Gal::SKIP_BUTTON)
        dispose_gal_event_balloon
      else
        @saba_balloon_sprite.update
      end
    end
  end
end

class Scene_Map
  include Saba::GalWindow
  #--------------------------------------------------------------------------
  # ● メッセージウィンドウの作成
  #--------------------------------------------------------------------------
  alias saba_gal_create_message_window create_message_window
  def create_message_window
    saba_gal_create_message_window
    create_gal_window
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias saba_gal_update update
  def update
    create_gal_window
    update_gal_event_balloon
    saba_gal_update
  end
  #--------------------------------------------------------------------------
  # ● スプライトセットの解放
  #--------------------------------------------------------------------------
  alias saba_gal_dispose_spriteset dispose_spriteset
  def dispose_spriteset
    saba_gal_dispose_spriteset
    dispose_gal_event_balloon
  end
end


class Scene_Battle
  include Saba::GalWindow
  #--------------------------------------------------------------------------
  # ● メッセージウィンドウの作成
  #--------------------------------------------------------------------------
  alias saba_gal_create_message_window create_message_window
  def create_message_window
    saba_gal_create_message_window
    create_gal_window
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias saba_gal_update_basic update_basic
  def update_basic
    create_gal_window
    update_gal_event_balloon
    saba_gal_update_basic
  end
  #--------------------------------------------------------------------------
  # ● スプライトセットの解放
  #--------------------------------------------------------------------------
  alias saba_gal_dispose_spriteset dispose_spriteset
  def dispose_spriteset
    saba_gal_dispose_spriteset
    dispose_gal_event_balloon
  end
end


class Window_MessageGal < Window_Message
  include Saba::Gal
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    self.x = 10
    create_baloon_sprite
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 20
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 改ページが必要か判定
  #--------------------------------------------------------------------------
  def need_new_page?(text, pos)
    pos[:y]  > contents.height && !text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 通常文字の処理
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    if Input.press?(SKIP_BUTTON) && skip_enabled?
      @pause_skip = true
    end
    text_width = text_size(c).width
    if display_name? && (pos[:y] == 0)
      @name_sprite.bitmap.draw_text(pos[:x], 26, text_width * 2, pos[:height], c)
      pos[:x] += text_width
      return
    end
    if display_name?
      draw_text(pos[:x], pos[:y] - pos[:height], text_width * 2, pos[:height], c)
    else
      draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    end
    pos[:x] += text_width
    unless Input.press?(SKIP_BUTTON) && skip_enabled?
      wait_for_one_character
    end
  end
  #--------------------------------------------------------------------------
  # ● 制御文字によるアイコン描画の処理
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    if display_name?
      draw_icon(icon_index, pos[:x], pos[:y] - pos[:height])
    else
      draw_icon(icon_index, pos[:x], pos[:y])
    end
    pos[:x] += 24
  end
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_all_windows
    super
    @name_window = Window_Base.new(20, Graphics.height - 126, NAME_WINDOW_WIDTH, 37)
    @name_window.z = 480
    @name_window.visible = false

    @name_sprite = Sprite_Base.new(nil)
    @name_sprite.z = 500
    @name_sprite.x = 30
    @name_sprite.y = Graphics.height - 146
    @name_sprite.bitmap = Bitmap.new(230, 300)
    
    @face_window = Window_Base.new(FACE_WINDOW_X, Graphics.height - FACE_WINDOW_BOTTOM, 128, FACE_WINDOW_HEIGHT)
    @face_window.padding = 0
    @face_window.opacity = 0
    @face_window.z = 400
  end
  #--------------------------------------------------------------------------
  # ● フキダシスプライトを生成します。
  #--------------------------------------------------------------------------
  def create_baloon_sprite
    @balloon_sprite = Sprite_Base.new
    @balloon_sprite.z = 500
    @balloon_sprite.y = Graphics.height - 384
    @balloon_sprite.bitmap = Bitmap.new(400, 300)
    @balloon_sprite.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの解放
  #--------------------------------------------------------------------------
  def dispose_all_windows
    super
    @name_window.dispose
    @name_sprite.bitmap.dispose
    @name_sprite.dispose
    @balloon_sprite.dispose
    @face_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの更新
  #--------------------------------------------------------------------------
  def update
    super
    update_name_visibility
    update_opacity
  end
  #--------------------------------------------------------------------------
  # ● 不透明度の更新
  #--------------------------------------------------------------------------
  def update_opacity
    if @background != 0
      self.opacity = 0
      return
    end
    return if self.opacity == 255
    self.opacity += 9
  end
  #--------------------------------------------------------------------------
  # ● 入力待ち処理
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) || (Input.press?(Saba::Gal::SKIP_BUTTON) && skip_enabled?)
    if self.visible == false
      self.visible = true
      Sound.play_cursor
      input_pause
      return
    end
    Input.update
    self.pause = false
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを開き、完全に開くまで待つ
  #--------------------------------------------------------------------------
  def open_and_wait
    @name_sprite.bitmap.clear
    open
    update_picture
    until open?
      update_balloon
      Fiber.yield 
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを閉じ、完全に閉じるまで待つ
  #--------------------------------------------------------------------------
  def close_and_wait
    return if $game_switches[NOT_CLOSE_WINDOW_SWITCH]
    close
    @name_window.visible = false
    @name_sprite.visible = false
    @balloon_sprite.visible = false
    until all_close?
      Fiber.yield
    end
  end
  #--------------------------------------------------------------------------
  # ● 改ページ処理
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    @name_sprite.bitmap.clear
    contents.clear
    if $game_message.position == 1 || $game_switches[SHOW_FACE_SWITCH]
      @face_window.contents.clear
      @face_window.draw_face($game_message.face_name, $game_message.face_index, 0, 0)
      @face_window.visible = true
      unless $game_switches[SHOW_FACE_SWITCH]
        $game_variables[BALLOON_VARIABLE] = FACE_WINDOW_COLOR
        @last_window_color = -1
      end
    else
      @face_window.visible = false
    end
    
    update_balloon
    update_balloon_visibility
    @last_window_color = -1 if $game_message.position == 1 # 次回更新用
    reset_font_settings
    pos[:x] = 0
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
  #--------------------------------------------------------------------------
  # ● 立ち絵の更新
  #--------------------------------------------------------------------------
  def update_picture
    return if $game_message.face_name.empty?
    if $game_message.position == 1
      $game_map.interpreter.actor_id = -1
      $game_map.interpreter.deactivate_other_pictures(1)
      draw_face($game_message.face_name, $game_message.face_index, 0, 0)
    else
      $game_map.interpreter.pic($game_message.face_name, $game_message.face_index, $game_message.position)
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ位置の更新
  #--------------------------------------------------------------------------
  def update_placement
    @position = 2
    self.y = @position * (Graphics.height - height) / 2
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
  end
  #--------------------------------------------------------------------------
  # ● 背景と位置の変更判定
  #--------------------------------------------------------------------------
  def settings_changed?
    @background != $game_message.background
  end
  #--------------------------------------------------------------------------
  # ● 改行位置の取得
  #--------------------------------------------------------------------------
  def new_line_x
    return 112 if $game_switches[SHOW_FACE_SWITCH]
    return $game_message.position != 1 ? 0 : 112
  end
  #--------------------------------------------------------------------------
  # ● 次の語を表示すべきかどうかを判定します。
  #--------------------------------------------------------------------------
  def show_next_message?
    if skip_enabled?
      return Input.trigger?(Input::C) || Input.trigger?(Input::B) || Input.trigger?(Saba::Gal::SKIP_BUTTON)
    else
      return Input.trigger?(Input::C) || Input.trigger?(Input::B)
    end
  end
  #--------------------------------------------------------------------------
  # ● メッセージスキップが有効かどうかを判定します。
  #--------------------------------------------------------------------------
  def skip_enabled?
    return $game_switches[SKIP_DISABLE_SWITCH] != true
  end
  #--------------------------------------------------------------------------
  # ● スイッチに従って、名前ウィンドウの表示を切り替えます。
  #--------------------------------------------------------------------------
  def update_name_visibility
    if @closing || close? || ! self.visible
      @name_window.visible = false
      @name_sprite.visible = false
      return
    end
    if $game_switches[DISPLAY_NAME_SWITCH] != true
      @name_window.visible = false
      @name_sprite.visible = false
    else
       @name_window.visible = true
      @name_sprite.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● ふきだしの表示を切り替えます。
  #--------------------------------------------------------------------------
  def update_balloon_visibility
    if $game_message.position == 1
      @balloon_sprite.visible = false
      return
    end  
    if self.openness < 255
      @balloon_sprite.visible = false
      return
    end
    if @balloon_sprite.visible != $game_switches[DISPLAY_BALLOON_SWITCH]
      @balloon_sprite.visible = $game_switches[DISPLAY_BALLOON_SWITCH]
    end
  end
  #--------------------------------------------------------------------------
  # ● 名前を表示すべきかどうかを判定します。
  #--------------------------------------------------------------------------
  def display_name?
    return $game_switches[DISPLAY_NAME_SWITCH] == true
  end
  #--------------------------------------------------------------------------
  # ● フキダシをまっさらにします。
  #--------------------------------------------------------------------------
  def clear_balloon
    @balloon_sprite.bitmap.clear_rect(100, 254, 300, 100)
  end
  #--------------------------------------------------------------------------
  # ● フキダシを更新します。
  #--------------------------------------------------------------------------
  def update_balloon
    window_color = $game_variables[BALLOON_VARIABLE]
    clear_balloon
    if USE_SINGLE_WINDOW_SKIN
      self.windowskin = Cache.system("Window1")
    else
      self.windowskin = Cache.system("Window" + window_color.to_s)
      if openness == 255 && ENBALE_WINDOW_CHANGE_TRANSITION
        self.opacity = 140 unless $game_switches[Saba::Gal::CLEAR_BALLOON_SWITCH]
      end
    end
  
    $game_switches[CLEAR_BALLOON_SWITCH] = false
    if window_color > 0
      if USE_SINGLE_WINDOW_SKIN
        balloon = Cache.system("Balloon1")
      else
        balloon = Cache.system("Balloon" + window_color.to_s)
      end
      w = balloon.width / 2
      h = balloon.height
      if $game_map.interpreter.center?
        @balloon_sprite.bitmap.blt(BALLOON_CENTER_X, BALLOON_Y, balloon, Rect.new(w, 0, w, h))
      elsif $game_variables[BALLOON_POSITION_VARIABLE] == 2
        @balloon_sprite.bitmap.blt(BALLOON_LEFT_X, BALLOON_Y, balloon, Rect.new(w, 0, w, h))
      else
        @balloon_sprite.bitmap.blt(BALLOON_RIGHT_X, BALLOON_Y, balloon, Rect.new(0, 0, w, h))
      end
    end
  end
  
end


class Game_Picture
  attr_accessor:mirror_pic
  alias saba_gal_initialze initialize
  def initialize(number)
    saba_gal_initialze(number)
    @mirror_pic = false
  end
end

class Sprite_Picture < Sprite
  alias saba_gal_update update
  def update
    saba_gal_update
    if @picture.name != ""
      self.mirror = @picture.mirror_pic
    end
  end
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップの更新
  #--------------------------------------------------------------------------
  alias saba_gal_update_bitmap update_bitmap
  def update_bitmap
    if @picture.name != @last_name
      saba_gal_update_bitmap
      @last_name = @picture.name
    end
  end
end

class Game_Pictures
  def size
    return @data.size
  end
end

class Game_Temp
  attr_accessor :pic_actors
  alias saba_pic_initialize initialize
  def initialize
    saba_pic_initialize
    @pic_actors = []
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● フキダシアイコンの表示
  #--------------------------------------------------------------------------
  alias saba_gal_command_213 command_213
  def command_213
    unless message_mode?
      saba_gal_command_213
      return
    end
    command = @list[@index + 1]
    if command == nil || command.code != 101
      p "イベントコマンドのフキダシアイコンの表示　の後にメッセージイベントを入れてください" 
      return
    end

    return if Input.press?(Saba::Gal::SKIP_BUTTON)
    params = command.parameters
    name = params[0]
    actor_id = name["actor".length..-1].to_i
    position = params[3]
    if $game_switches[CENTER_SWITCH]
      if position == 0 && screen.pictures[2 + 10].name.empty?
        position = 1
      elsif position == 2 && screen.pictures[0 + 10].name.empty?
        position = 1
      end
    end
    #position = 1 if appear_from_center?
    x = (picture_base_x(position) + offset_event_balloon_x(position, actor_id) + 80) / 32.0 + $game_map.display_x
    y = (picture_base_y(position) + offset_event_balloon_y(actor_id)) / 32.0 + $game_map.display_y
    balloon_char = Game_Character.new
    balloon_char.moveto(x, y)
    balloon_char.balloon_id = @params[1]
    SceneManager.scene.create_gal_event_balloon(balloon_char)
  end
  #--------------------------------------------------------------------------
  # ● 会話モードかどうかを判定します。
  #--------------------------------------------------------------------------
  def message_mode?
    return $game_switches[Saba::Gal::MESSAGE_MODE_SWITCH] == true
  end
end