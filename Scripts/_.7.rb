#==============================================================================
# ■ メッセージログ4
#   @version 0.5 11/12/30
#   @author さば缶
#------------------------------------------------------------------------------
# 　
#==============================================================================
module Saba
  module MessageLog
    # メッセージログ表示ボタン
    LOG_BUTTON = Input::X
    
    # 各メッセージの間のスペース
    Y_SPACE = 10
    
    # 最大メッセージ保持数
    # ※あまり巨大な数だと、ビットマップサイズの限界を超えてエラーになります
    MAX_HISTORY = 50
    
    # 背景色
    BG_COLOR = Color.new(0, 0, 0, 180)
    
    # スクロール速度
    SCROLL_SPEED = 5
    
    # フォントサイズ
    FONT_SIZE = 20
    
    # 行の高さ
    LINE_HEIGHT = 22
    
    # 名前欄の横幅
    NAME_WIDTH = 100
  end
end

$imported = {} if $imported == nil
$imported["MessageLog"] = true

class Window_MessageLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    self.active = true
    self.opacity = 0
    create_back_sprite
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ログに必要な高さを計算
  #--------------------------------------------------------------------------
  def calc_log_height
    return @log_height if @log_height != nil
    @log_height = 0
    for log in $game_message_log.logs
      
      log.texts.each_with_index do |text, i|
        next if i == 0 && log.talk
        @log_height += 24
      end
      @log_height += Saba::MessageLog::Y_SPACE
    end
    return @log_height
  end
  #--------------------------------------------------------------------------
  # ● 背景スプライトの作成
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Bitmap.new(window_width, window_height)
    bg_color = Saba::MessageLog::BG_COLOR
    @back_sprite.bitmap.fill_rect(Rect.new(0, 0, window_width, window_height), bg_color)
    @back_sprite.visible = true
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
    Graphics.height
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    y = 0
    for log in $game_message_log.logs
      talk = false
      log.texts.each_with_index do |text, i|
        
        if i == 0 && log.talk
          talk = true
        end
        
        x = (talk && i == 0) ? 0 : Saba::MessageLog::NAME_WIDTH
        draw_text_ex(x-16, y, "「") if talk && i == 1
        text += "」" if talk && log.texts.size - 1 == i
        draw_text_ex(x, y, text)
        y += Saba::MessageLog::LINE_HEIGHT if ! talk || i > 0
        
      end
      y += Saba::MessageLog::Y_SPACE
    end
    
    @max_oy = [0, calc_log_height - window_height + 32].max
    self.oy = @max_oy
  end
  #--------------------------------------------------------------------------
  # ● フォント設定のリセット
  #--------------------------------------------------------------------------
  def reset_font_settings
    change_color(normal_color)
    contents.font.size = Saba::MessageLog::FONT_SIZE
    contents.font.bold = false
    contents.font.italic = false
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の作成
  #--------------------------------------------------------------------------
  def create_contents
    contents.dispose
    self.contents = Bitmap.new(window_width-32, [window_height-32, calc_log_height-32].max)
  end
  def update
    super
    if Input.press?(Input::DOWN)
      self.oy += Saba::MessageLog::SCROLL_SPEED
    end
    if Input.press?(Input::UP)
      self.oy -= Saba::MessageLog::SCROLL_SPEED
    end
    self.oy = 0 if self.oy < 0
    self.oy = @max_oy if self.oy > @max_oy
  end
end

class Game_MessageLog
  attr_reader :texts
  attr_reader :talk
  def initialize(texts)
    @texts = texts
    if $imported["GalGameTalkSystem"]
      @talk = $game_switches[Saba::Gal::DISPLAY_NAME_SWITCH]
    else
      @talk = false
    end
  end
  def ==(arg)
    return arg.instance_of?(self.class) && @texts == arg.texts
  end
end

class Game_MessageLogSet
  attr_accessor:logs
  
  def initialize
    @logs = []
  end
  def push_log(texts)
    return if texts == nil || texts.size == 0
    log = Game_MessageLog.new(texts)
    return if @logs[-1] == log 
    @logs.push(log)
    @logs.shift if @logs.size > Saba::MessageLog::MAX_HISTORY
  end
end

class Scene_Map
  #--------------------------------------------------------------------------
  # ● シーン遷移に関連する更新
  #--------------------------------------------------------------------------
  alias saba_msglog_update update
  def update
    saba_msglog_update
    update_call_msg_log unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ● メッセージログ呼び出し判定
  #--------------------------------------------------------------------------
  def update_call_msg_log
    call_msglog if Input.trigger?(Saba::MessageLog::LOG_BUTTON)
  end
  def call_msglog
    Sound.play_ok
    SceneManager.call(Scene_MsgLog)
  end
end

class Scene_MsgLog < Scene_MenuBase
   #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @log_window = Window_MessageLog.new
    @log_window.set_handler(:cancel,    method(:return_scene))
  end
end

class Window_Message
  alias saba_msglog_process_all_text process_all_text
  def process_all_text
    $game_message_log.push_log($game_message.texts)
    saba_msglog_process_all_text
  end
end

class << DataManager
  #--------------------------------------------------------------------------
  # ● 各種ゲームオブジェクトの作成
  #--------------------------------------------------------------------------
  alias saba_msglog_create_game_objects create_game_objects
  def create_game_objects
    saba_msglog_create_game_objects
    $game_message_log          = Game_MessageLogSet.new
  end
  #--------------------------------------------------------------------------
  # ● セーブ内容の作成
  #--------------------------------------------------------------------------
  alias saba_msglog_make_save_contents make_save_contents
  def make_save_contents
    contents = saba_msglog_make_save_contents
    contents[:message_log] = $game_message_log
    contents
  end
  #--------------------------------------------------------------------------
  # ● セーブ内容の展開
  #--------------------------------------------------------------------------
  alias saba_msglog_extract_save_contents extract_save_contents
  def extract_save_contents(contents)
    saba_msglog_extract_save_contents(contents)
    $game_message_log        = contents[:message_log]
  end
end