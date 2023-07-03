#==============================================================================
# RGSS3_FF風 画面上部にスキル名表示 ver1.10
# 2012/06/29公開
# 2012/08/02使用者表示を追加
# 2012/08/11不具合修正
# 2012/08/13アイコン表示を追加
# 2012/11/01不具合修正  BATTLE_LOG_DOWN の設定方法(trueとfalse)を逆に
# 2012/11/13 XPスタイルバトル併用の設定項目を追加
# 2014/03/31サイドビュー、XPスタイルバトルの対応スクリプトを本体に統合
# 2014/06/18スクリプト整理
# 2014/06/25スクリプト整理
# 2014/10/18 XP併用 BATTLELOG_TYPE=2 の行動前後でウェイトしなかったのを修正
# 2014/11/18 XP併用 BATTLELOG_TYPE=0 のログ背景がずれていたのを修正
#                   BATTLELOG_TYPE=2 で反撃と反射での戦闘不能時のエラーを修正
# C Winter (http://ccwinter.blog.fc2.com/)
#==============================================================================

#==============================================================================
# ■ 設定項目
#==============================================================================
module Top_Skill
  
  BATTLE_LOG_DOWN = true
    # バトルログ表示位置の高さ
    #　 trueなら常に下げる　falseならスキル名ウインドウが表示された時のみ下げる
  
  USE_BATTLE_LOG = true
    # スキル名ウインドウを表示した時は、通常の使用メッセージも出すかどうか
    #　 trueなら出す　falseなら出さない
  
  DEFAULT_SHOW = true
    # スキル・アイテムで<上表示あり><上表示なし>を省略した場合のデフォルト表示
    #　 trueなら表示　falseなら非表示
  DEFAULT_WINDOW_MODE = false
    # <表示モード=true><表示モード=false>を省略した場合のデフォルト表示モード
    #　 trueなら半透明ウインドウ　falseなら通常ウインドウ
    
  ACTOR_ATTACK = true
    # 味方の通常攻撃時の表示内容
    #   nilなら非表示　文字列（  "通常攻撃"  など）ならその文字列
    #　 trueなら武器から取得　falseならキャラから取得
    # 文字列を指定した場合、内容以外の設定（表示モードなど）はデフォルトのもの
  ACTOR_NO_WEAPON_NAME = "素手"
    #   DEFAULT_ACTOR_ATTACK_MESSAGE = trueで武器を装備していない場合の表示内容
    # 武器を装備していない場合、内容以外の設定（表示モードなど）はデフォルトのもの
  
  ENEMY_ATTACK = "通常攻撃"
    # 敵の通常攻撃時の内容
    # 　nilなら非表示　文字列ならその文字列　falseならキャラから取得
    # 文字列を指定した場合、内容以外の設定（表示モードなど）はデフォルトのもの
  
  
  # 表示内容の前に使用者名を表示するかどうか
  ACTOR_NO_WEAPON_ATTACK_USERNAME  = true # 味方通常攻撃　武器無し
  ACTOR_USE_WEAPON_ATTACK_USERNAME = true # 味方通常攻撃　武器装備中
  ENEMY_ATTACK_USERNAME = true # 敵通常攻撃
  DEFAULT_USERNAME = true # それ以外の場合
  
  # 使用者名を表示する場合、使用者名の直後に付け加える文字列
  USERNAME_ADD = "　"
  
  
  # メモ指定がない場合、使用者名と表示内容の前にアイコンを表示するかどうか
    #  trueならスキルID1のアイコン falseなら表示しない nilなら武器アイコン
  ACTOR_ATTACK_ICON = nil  # 武器のメモ指定がない場合の味方の通常攻撃
    #  trueならスキルID1のアイコン falseなら表示しない
  ENEMY_ATTACK_ICON = true # 敵キャラのメモ指定がない場合の敵の通常攻撃
    #  trueならスキル・アイテムのアイコン falseなら表示しない
  DEFAULT_ICON = true      # メモ指定がない場合のスキル・アイテム
  
  
  
  # ※以下　XPスタイルバトル併用で、バトルログタイプが蓄積型の時のみ
  
  # 蓄積型ログを消すタイミング
  #  trueなら元と同じ（XPスタイルコンフィグ84行目 STORAGE_TURNEND_CLEAR による）
  #  falseなら行動後にスキル名ウインドウを消すのと同時にログも消す
  XP_LOG_CLEAR_TIMING = false
  # 蓄積型ログの消え方
  #  trueなら元と同じ（時間ごとに薄くなっていく） falseなら一瞬で完全に消える
  XP_LOG_CLEAR_TYPE = true
  
end



#==============================================================================
# ■ Top_Skill
#==============================================================================
module Top_Skill
  def self.xp_style?
    return ($lnx_include != nil and $lnx_include[:lnx11a] != nil)
  end
  def self.sideview?
    begin
      N03::ACTOR_POSITION
      return true
    rescue
      return false
    end
  end
end

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  def top_message_data
    if @note =~ /<上表示あり>/
      flag = true
    elsif @note =~ /<上表示なし>/
      flag = false
    else
      flag = Top_Skill::DEFAULT_SHOW
    end
    if flag
      return [top_message, top_window_mode, top_message_color,
              top_window_color, top_message_username]
    else
      return nil
    end
  end
  def top_message
    if @note =~ /<表示内容=(\S+?)>/
      return $1.to_s
    else
      return @name
    end
  end
  def top_window_mode
    return true if @note =~ /<表示モード=true>/
    return false if @note =~ /<表示モード=false>/
    return Top_Skill::DEFAULT_WINDOW_MODE
  end
  def top_message_color
    return @note =~ /<文字色=(\d*),(\d*),(\d*)>/ ? 
      Color.new($1.to_i, $2.to_i, $3.to_i, 255) : Color.new(255, 255, 255, 255)
  end
  def top_window_color
    return @note =~ /<ウインドウ色=(\-*\d+),(\-*\d+),(\-*\d+)>/ ? 
              Tone.new($1.to_i, $2.to_i, $3.to_i) : $game_system.window_tone
  end
  def top_message_username
    return true if @note =~ /<使用者名=true>/
    return false if @note =~ /<使用者名=false>/
    return Top_Skill::DEFAULT_USERNAME
  end
  def top_message_icon
    return nil if @note =~ /<表示アイコン=false>/
    return $1.to_i if @note =~ /<表示アイコン=(\d+)>/i
    return self.icon_index if @note =~ /<表示アイコン=true>/
    return self.icon_index if Top_Skill::DEFAULT_ICON
    return nil
  end
end

class RPG::Weapon
  def top_message_username
    return true if @note =~ /<使用者名=true>/
    return false if @note =~ /<使用者名=false>/
    return Top_Skill::ACTOR_USE_WEAPON_ATTACK_USERNAME
  end
  def top_message_icon
    return false if @note =~ /<表示アイコン=false>/
    return $1.to_i if @note =~ /<表示アイコン=(\d+)>/i
    return self.icon_index if @note =~ /<表示アイコン=true>/
    return self.icon_index if Top_Skill::ACTOR_ATTACK_ICON == nil
    return nil
  end
end
class RPG::Actor
  def top_message_username
    return true if @note =~ /<使用者名=true>/
    return false if @note =~ /<使用者名=false>/
    return Top_Skill::ACTOR_NO_WEAPON_ATTACK_USERNAME
  end
end
class RPG::Enemy
  def top_message_username
    return true if @note =~ /<使用者名=true>/
    return false if @note =~ /<使用者名=false>/
    return Top_Skill::ENEMY_ATTACK_USERNAME
  end
end
#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor
  def attack_top_message_data
    if Top_Skill::ACTOR_ATTACK == nil
      return nil
    elsif Top_Skill::ACTOR_ATTACK.is_a?(String)
      return [Top_Skill::ACTOR_ATTACK, Top_Skill::DEFAULT_WINDOW_MODE,
                Color.new(255, 255, 255, 255), $game_system.window_tone,
                Top_Skill::ACTOR_NO_WEAPON_ATTACK_USERNAME]
    elsif Top_Skill::ACTOR_ATTACK == true
      if weapons[0]
        return weapons[0].top_message_data
      else
        return [Top_Skill::ACTOR_NO_WEAPON_NAME, Top_Skill::DEFAULT_WINDOW_MODE,
                Color.new(255, 255, 255, 255), $game_system.window_tone,
                Top_Skill::ACTOR_NO_WEAPON_ATTACK_USERNAME]
      end
    elsif Top_Skill::ACTOR_ATTACK == false
      return actor.top_message_data
    end
  end
  def top_message_icon
    icon = weapons[0] ? weapons[0].top_message_icon : nil
    icon = $data_skills[1].icon_index if icon == nil and
           Top_Skill::ACTOR_ATTACK_ICON == true
    return icon
  end
end
#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy
  def attack_top_message_data
    if Top_Skill::ENEMY_ATTACK == nil
      return nil
    elsif Top_Skill::ENEMY_ATTACK.is_a?(String)
      return [Top_Skill::ENEMY_ATTACK, Top_Skill::DEFAULT_WINDOW_MODE,
                Color.new(255, 255, 255, 255), $game_system.window_tone,
                Top_Skill::ENEMY_ATTACK_USERNAME]
    elsif Top_Skill::ENEMY_ATTACK == false
      return enemy.top_message_data
    end
  end
  def top_message_icon
    return false if enemy.note =~ /<表示アイコン=false>/
    return $1.to_i if enemy.note =~ /<表示アイコン=(\d+)>/i
    return $data_skills[1].icon_index if Top_Skill::ENEMY_ATTACK_ICON == true
    return nil
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias :top_skill_name_create_all_windows :create_all_windows
  def create_all_windows
    top_skill_name_create_all_windows
    @top_skill_name_window = Window_TopSkillName.new
    hide_top_skill_name_window
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行
  #--------------------------------------------------------------------------
  alias :top_skill_name_execute_action :execute_action
  def execute_action
    top_skill_name_execute_action
    hide_top_skill_name_window
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    display_top_skill(item)
    
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    show_animation(targets, item.animation_id)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
    xp_after_use_item_wait(item)
  end
  def xp_before_use_item_wait(item)
  end
  def xp_after_use_item_wait(item)
  end
  #--------------------------------------------------------------------------
  # ● スキル名ウインドウを表示
  #--------------------------------------------------------------------------
  def display_top_skill(item)
    display_top_skill_name_window(item)
    if Top_Skill::USE_BATTLE_LOG or @top_skill_name_window.visible == false
      @log_window.display_use_item(@subject, item)
    end
    xp_before_use_item_wait(item)
  end
  def display_top_skill_name_window(item)
    if item.is_a?(RPG::Skill) and item.id == 1  # 通常攻撃の場合
      data = @subject.attack_top_message_data
    else
      data = item.top_message_data
    end
    
    return @top_skill_name_window.draw_background(false) if data == nil
    
    data = convert_top_skill_data(data, item, @subject)
    
    down_log_window(true)
    @top_skill_name_window.set_data(data)
  end
  #--------------------------------------------------------------------------
  # ● データ変換
  #--------------------------------------------------------------------------
  def convert_top_skill_data(data, item, user)
    data = convert_top_skill_data_user_name(data, item, user)
    data = convert_top_skill_data_icon(data, item, user)
    data = convert_top_skill_data_ae_window_color(data, item, user)
    return data
  end
  def convert_top_skill_data_user_name(data, item, user)
    if data[4]
      data[6] = user.top_display_name
    else
      data[6] = ""
    end
    return data
  end
  def convert_top_skill_data_icon(data, item, user)
    if item.is_a?(RPG::Skill) and item.id == 1  # 通常攻撃の場合
      icon = @subject.top_message_icon
    else
      icon = item.top_message_icon
    end
    data[5] = icon
    return data
  end
  def convert_top_skill_data_ae_window_color(data, item, user)
    return data
  end
  #--------------------------------------------------------------------------
  # ● バトルログを下げる
  #--------------------------------------------------------------------------
  def down_log_window(flag)
    flag = true if Top_Skill::BATTLE_LOG_DOWN
    default_down_log_window(flag)
  end
  def default_down_log_window(flag)
    @log_window.y = flag ? 36 : 0
    @log_window.dispose_back_sprite
    @log_window.create_back_sprite
  end
  #--------------------------------------------------------------------------
  # ● スキル名ウインドウを隠す
  #--------------------------------------------------------------------------
  def hide_top_skill_name_window
    @top_skill_name_window.draw_background(false)
    @top_skill_name_window.hide
    down_log_window(false)
  end
end
#==============================================================================
# ■ Window_TopSkillName
#==============================================================================
class Window_TopSkillName < Window_Help
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @color_data = $game_system.window_tone
    super(1)
    hide
    create_back_bitmap
    create_back_sprite
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_back_bitmap
    dispose_back_sprite
  end
  #--------------------------------------------------------------------------
  # ● 内容を設定
  #--------------------------------------------------------------------------
  def set_data(data)
    draw_background(data[1])
    change_color(data[2])
    update_tone(data[3])
    @text = data[0]
    @icon = data[5]
    @user_name = data[6]
    refresh
    show
  end
  #--------------------------------------------------------------------------
  # ● 背景の描画
  #--------------------------------------------------------------------------
  def draw_background(flag)
    @back_bitmap.clear
    @back_bitmap.fill_rect(back_rect, back_color) if flag
    self.opacity = flag ? 0 : 255
  end
  #--------------------------------------------------------------------------
  # ● 色調の更新
  #--------------------------------------------------------------------------
  def update_tone(color_data = nil)
    @color_data = color_data if color_data
    self.tone.set(@color_data)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    name_flag = !@user_name.empty?
    if name_flag
       @text = @user_name + Top_Skill::USERNAME_ADD + @text
    end
    rect = text_size(@text)
    rect.x = (contents_width - rect.width) / 2
    draw_icon(@icon, rect.x - 24, 0) if @icon
    draw_text_ex(rect.x, 0, @text)
  end
  #--------------------------------------------------------------------------
  # ● 制御文字つきテキストの描画
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  
  #--------------------------------------------------------------------------
  # ● 背景ビットマップの作成
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Bitmap.new(width, height)
  end
  #--------------------------------------------------------------------------
  # ● 背景スプライトの作成
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.y = y
    @back_sprite.z = z - 1
  end
  #--------------------------------------------------------------------------
  # ● 背景ビットマップの解放
  #--------------------------------------------------------------------------
  def dispose_back_bitmap
    @back_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 背景スプライトの解放
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 背景の矩形を取得
  #--------------------------------------------------------------------------
  def back_rect
    Rect.new(0, padding, width, line_height)
  end
  #--------------------------------------------------------------------------
  # ● 背景色の取得
  #--------------------------------------------------------------------------
  def back_color
    Color.new(0, 0, 0, back_opacity)
  end
  #--------------------------------------------------------------------------
  # ● 背景の不透明度を取得
  #--------------------------------------------------------------------------
  def back_opacity
    return 64
  end
end

if Top_Skill.sideview?
#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    display_top_skill(item)
    @log_window.off if !N03::BATTLE_LOG
    
    @subject.use_item(item)
    refresh_status
    @targets = @subject.current_action.make_targets.compact
    @targets = [@subject] if @targets.size == 0
    set_substitute(item)
    for time in item.repeats.times do play_sideview(@targets, item) end
    end_reaction(item)
    display_end_item
    xp_after_use_item_wait(item)
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテム名の表示終了
  #--------------------------------------------------------------------------
  def display_end_item
    set_camera_wait(N03::ACTION_END_WAIT) if @subject.sv.derivation_skill_id == 0
    @log_window.clear if N03::BATTLE_LOG
    hide_top_skill_name_window
  end
end
#==============================================================================
# ■ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 背景スプライトの作成
  #--------------------------------------------------------------------------
  alias :sv_top_skill_name_create_back_sprite :create_back_sprite
  def create_back_sprite
    sv_top_skill_name_create_back_sprite
    off if !N03::BATTLE_LOG
  end
end
end

if Top_Skill.xp_style?
#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● バトルログを下げる
  #--------------------------------------------------------------------------
  def down_log_window(flag)
    flag = true if Top_Skill::BATTLE_LOG_DOWN
    if LNX11::BATTLELOG_TYPE == 1
      down_y = flag ? (36 + LNX11::STORAGE_OFFSET[:y]) : 0
      @log_window.mes_sprites_set_down_y(down_y)
    elsif LNX11::BATTLELOG_TYPE == 0
      default_down_log_window(flag)
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル名ウインドウを隠す
  #--------------------------------------------------------------------------
  def hide_top_skill_name_window
    @top_skill_name_window.draw_background(false)
    @top_skill_name_window.hide
    down_log_window(false)
    $game_temp.battlelog_clear = true if Top_Skill::XP_LOG_CLEAR_TIMING == false
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  def xp_before_use_item_wait(item)
    item = @subject.current_action.item
    if LNX11::BATTLELOG_TYPE == 2 && @top_skill_name_window.visible
      duration = item.display_wait
      @wait_short_disabled = false
      wait(duration ? duration : 20)  # helpdisplay_setから
    end
  end
  def xp_after_use_item_wait(item)
    if LNX11::BATTLELOG_TYPE == 2
      wait(item.end_wait)
      if @top_skill_name_window.visible
        @wait_short_disabled = false
        wait(10)   # helpdisplay_clearから
      end
    end
    wait_for_effect
  end
end
#==============================================================================
# ■ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● ログの位置を下げる
  #--------------------------------------------------------------------------
  def mes_sprites_set_down_y(down_y)
    @mes_sprites.each {|sprite| sprite.down_y = down_y}
  end
end
#==============================================================================
# ■ Sprite_OneLine_BattleLog
#==============================================================================
class Sprite_OneLine_BattleLog < Sprite
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :down_y
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    return if self.opacity == 0
    if Top_Skill::XP_LOG_CLEAR_TYPE == false and @position < 0
      self.opacity = 0
    else
      self.opacity += @visible && @position >= 0 ? 24 : -24
    end
    self.visible = self.opacity > 0
    return unless @visible # 不可視状態なら座標を更新しない
    @ry = (target_y + (@ry * 5)) / 6.0 if target_y < @ry
    @rx += 2 if @rx < 0
    self.x = @rx
    self.y = @ry + @down_y
  end
end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  def top_display_name; return @name; end
end
#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  def top_display_name; return name; end
# def top_display_name; return @original_name; end
# にすると"スライム A"などが"スライム"になる
end