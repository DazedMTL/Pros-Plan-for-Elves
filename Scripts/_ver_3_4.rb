=begin

 ▼ 選択肢拡張 ver. 3.4
 
 RPGツクールVXAce用スクリプト
 
 制作 : 木星ペンギン
 URL  : http://woodpenguin.blog.fc2.com/

------------------------------------------------------------------------------
 概要

 □ 選択肢を連続して設定した場合、つなげて一つの選択肢にする機能の追加。
 □ 条件を設定することで、その項目を表示しない機能の追加。
 □ 選択肢のカーソル初期位置を指定する機能と
    現在のカーソル位置を変数に入れる機能の追加。
 
 □ 選択肢ウィンドウの位置を一時的に変更する機能の追加。
 □ 条件を設定することで、その項目を半透明にして選択不可にする機能の追加。
 □ 選択肢毎にヘルプメッセージを表示できる機能の追加。

------------------------------------------------------------------------------
 使い方
 
 □ 選択肢の表示を続けて配置すると、一つの選択肢にまとめられます。
  ・「キャンセルの場合」の処理は、無効以外を設定したものが適用され、
     複数ある場合は後の選択肢のものが適用されます。
  
 □ 選択肢の文章中に if(条件) と入れ、その条件が偽になると項目が表示されなくなります。
  ・条件は eval によって評価されます。（詳細は【組み込み関数】を参照）
  ・s でスイッチ、v で変数を参照できます。
  ・「キャンセルの場合」の項目が表示されない場合、無効と同じ処理をします。

 □ 注釈に以下の文字列を入れることで、指定された変数の値が
    カーソルの初期位置になります。
  
  　　カーソル記憶(n)
    
      n : カーソル初期位置の入った変数番号
  
  ・選択肢のカーソルの位置が変更されるたびに、
    この変数に選択肢の番号が入れられるようになります。
  
 □ 注釈に以下の文字列を入れることで、選択肢ウィンドウの表示位置を
  　一時的に変更することが出来ます。
  
  　　選択肢位置(x, y[, row])
    
      x   : ウィンドウを表示する X 座標。
      y   : ウィンドウを表示する Y 座標。
      row : 選択肢を表示する最大行数。
            指定しない場合は、通常の最大行数を無視して
            すべての選択肢が表示されます。
  
 □ 注釈に以下の文字列を入れることで、メッセージの下に選択肢を
  　表示させます。
    [文章の表示]をこの後に実行してください。
  
  　　選択肢位置(メッセージ下)
    
 □ 注釈に以下の文字列を入れることで、選択肢ウィンドウの背景が非表示になります。
  
  　　背景OFF
    
 □ 選択肢の文章中に en(条件) と入れ、その条件が偽になると項目が半透明で表示されます。
  ・条件は eval によって評価されます。（詳細は【組み込み関数】を参照）
  ・s でスイッチ、v で変数を参照できます。
  ・「キャンセルの場合」の項目が半透明の場合、ブザーが鳴ります。
  
 □ 各項目の下に、注釈で以下の文字列を入れると、続きの注釈を
    項目のヘルプメッセージとしてカーソルを合わせたときに標示することができます。
  
  　　選択肢ヘルプ
    
 □ 詳細は下記のサイトを参照してください。

  http://woodpenguin.web.fc2.com/rgss3/choice_ex.html
  
=end
module WdTk
module ChoiceEX
#//////////////////////////////////////////////////////////////////////////////
#
# 設定項目
#
#//////////////////////////////////////////////////////////////////////////////
  #--------------------------------------------------------------------------
  # ● 選択肢の最大行数
  #     選択肢を表示するウィンドウの行数の最大数です。
  #     選択肢がこの数より小さければ、選択肢の数に合わせます。
  #--------------------------------------------------------------------------
  RowMax = 12
  
  #--------------------------------------------------------------------------
  # ● 選択肢ヘルプを読み取る文字列
  #--------------------------------------------------------------------------
  Help = "選択肢ヘルプ"
  
end

#//////////////////////////////////////////////////////////////////////////////
#
# 以降、変更する必要なし
#
#//////////////////////////////////////////////////////////////////////////////

  @material ||= []
  @material << :ChoiceEX
  def self.include?(sym)
    @material.include?(sym)
  end
  
end

#==============================================================================
# ■ Game_Message
#==============================================================================
class Game_Message
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :choice_x                 # 選択肢ウィンドウの表示 X 座標
  attr_accessor :choice_y                 # 選択肢ウィンドウの表示 Y 座標
  attr_accessor :choice_row_max           # 選択肢ウィンドウの表示行数
  attr_accessor :choice_help              # 選択肢のヘルプ
  attr_accessor :choice_var_id            # 選択肢のカーソル位置を入れる変数ID
  attr_accessor :choice_background        # 選択肢ウィンドウ背景の表示状態
  attr_accessor :under_choice             # 選択肢をメッセージの下に表示
  #--------------------------------------------------------------------------
  # ○ クリア
  #--------------------------------------------------------------------------
  alias _wdtk_choice_clear clear
  def clear
    _wdtk_choice_clear
    @choice_x = @choice_y = nil
    @choice_row_max = WdTk::ChoiceEX::RowMax
    @choice_help = {}
    @choice_var_id = 0
    @choice_background = 0
    @under_choice = false
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ☆ 選択肢のセットアップ
  #--------------------------------------------------------------------------
  def setup_choices(params)
    add_choices(params, @index)
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● 選択肢の追加
  #--------------------------------------------------------------------------
  def add_choices(params, i, d = 0)
    params[0].each_with_index {|s, n| $game_message.choices[n + d] = s }
    $game_message.choice_cancel_type = params[1] + d if params[1] > 0
    indent = @list[i].indent
    loop do
      i += 1
      if @list[i].indent == indent
        case @list[i].code
        when 402 # [**] の場合
          get_help_texts(@list[i].parameters[0] + d, i + 1)
        when 404 # 分岐終了
          break
        end
      end
    end
    i += 1
    add_choices(@list[i].parameters, i, d + 5) if @list[i].code == 102
  end
  #--------------------------------------------------------------------------
  # ● ヘルプ用テキストの取得
  #--------------------------------------------------------------------------
  def get_help_texts(b, i)
    if @list[i].code == 108 && @list[i].parameters[0] == WdTk::ChoiceEX::Help
      $game_message.choice_help[b] = []
      while @list[i + 1].code == 408
        i += 1
        $game_message.choice_help[b] << @list[i].parameters[0]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◯ 注釈
  #--------------------------------------------------------------------------
  alias _wdtk_choice_command_108 command_108
  def command_108
    _wdtk_choice_command_108
    @comments.each do |comment|
      case comment
      when /選択肢位置\((\d+),\s*(\d+),?\s*(\d*)\)/
        $game_message.choice_x = $1.to_i
        $game_message.choice_y = $2.to_i
        $game_message.choice_row_max = ($3.empty? ? 99 : $3.to_i)
      when "選択肢位置(メッセージ下)"
        $game_message.under_choice = true
        $game_message.choice_background = 1
      when /カーソル記憶\((\d+)\)/
        $game_message.choice_var_id = $1.to_i
      when /背景(ON|OFF)/
        $game_message.choice_background = ($1 == "ON" ? 0 : 1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 分岐終了の場合
  #--------------------------------------------------------------------------
  def command_404
    if next_event_code == 102
      @branch[@indent] -= 5 if @branch.include?(@indent)
      @index += 1
      command_skip
    end
  end
end

#==============================================================================
# ■ Window_ChoiceList
#==============================================================================
class Window_ChoiceList
  #--------------------------------------------------------------------------
  # ☆ 入力処理の開始
  #--------------------------------------------------------------------------
  def start
    return unless close?
    clear_command_list
    make_command_list
    if @list.empty?
      $game_message.choice_proc.call(-1)
      return
    end
    update_placement
    refresh
    select(0)
    if $game_message.choice_var_id > 0
      select_ext($game_variables[$game_message.choice_var_id])
    end
    open
    activate
  end
  #--------------------------------------------------------------------------
  # ☆ ウィンドウ位置の更新
  #--------------------------------------------------------------------------
  def update_placement
    self.width = [max_choice_width + 12, 96].max + padding * 2
    self.width = [width, Graphics.width].min
    n = [@list.size, $game_message.choice_row_max].min
    self.height = fitting_height(n)
    self.x = Graphics.width - width
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height
    else
      self.y = @message_window.y + @message_window.height
    end
    self.x = $game_message.choice_x if $game_message.choice_x
    self.y = $game_message.choice_y if $game_message.choice_y
    self.z = $game_message.under_choice ? 210 : 100
  end
  #--------------------------------------------------------------------------
  # ☆ 選択肢の最大幅を取得
  #--------------------------------------------------------------------------
  def max_choice_width
    @list.collect {|com| text_size(com[:name]).width }.max || 0
  end
  #--------------------------------------------------------------------------
  # ☆ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    $game_message.choices.each_with_index do |choice, i|
      next unless choice
      str = choice.dup
      next if str.slice!(/\s*if\(([^\)]+)\)/i) && !choice_eval($1)
      enable = !str.slice!(/\s*en\(([^\)]+)\)/i) || choice_eval($1)
      add_command(str, :choice, enable, i)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  alias _wdtk_choice_draw_item draw_item
  def draw_item(index)
    @choice_enabled = command_enabled?(index)
    _wdtk_choice_draw_item(index)
  end
  #--------------------------------------------------------------------------
  # ● テキスト描画色の変更
  #--------------------------------------------------------------------------
  def change_color(color, enabled = true)
    super(color, enabled && @choice_enabled)
  end
  #--------------------------------------------------------------------------
  # ☆ 決定ハンドラの呼び出し
  #--------------------------------------------------------------------------
  def call_ok_handler
    $game_message.choice_proc.call(current_ext)
    close
  end
  #--------------------------------------------------------------------------
  # ● キャンセルボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_cancel
    return super if $game_message.choice_cancel_type % 5 == 0
    index = @list.index {|c| c[:ext] == $game_message.choice_cancel_type - 1 }
    return unless index
    return super if command_enabled?(index)
    Sound.play_buzzer
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを閉じる
  #--------------------------------------------------------------------------
  def close
    @message_window.on_show_fast unless $game_message.choice_help.empty?
    super
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active && !$game_message.choice_help.empty?
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    @message_window.force_clear
    if $game_message.choice_help.include?(current_ext)
      $game_message.texts.replace($game_message.choice_help[current_ext])
    else
      $game_message.texts.clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 分岐用
  #--------------------------------------------------------------------------
  def choice_eval(formula)
    s, v = $game_switches, $game_variables
    begin
      Kernel.eval(formula)
    rescue
      msgbox "以下の条件判定でエラーが出ました。\n\n", formula
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    last_index = @index
    super
    if last_index != @index && $game_message.choice_var_id > 0
      $game_variables[$game_message.choice_var_id] = current_ext
    end
  end
end

#==============================================================================
# ■ Window_Message
#==============================================================================
class Window_Message
  #--------------------------------------------------------------------------
  # ○ ウィンドウ背景の更新
  #--------------------------------------------------------------------------
  alias _wdtk_choice_update_background update_background
  def update_background
    _wdtk_choice_update_background
    @choice_window.opacity = $game_message.choice_background == 0 ? 255 : 0
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ位置の更新
  #--------------------------------------------------------------------------
  alias _wdtk_choice_update_placement update_placement
  def update_placement
    _wdtk_choice_update_placement
    reset_under_choice
  end
  #--------------------------------------------------------------------------
  # ○ 改行文字の処理
  #--------------------------------------------------------------------------
  alias _wdtk_choice_process_new_line process_new_line
  def process_new_line(text, pos)
    if $game_message.under_choice
      $game_message.choice_y += pos[:height]
      ch = self.contents_height + self.y - $game_message.choice_y
      $game_message.choice_row_max = ch / line_height
    end
    _wdtk_choice_process_new_line(text, pos)
  end
  #--------------------------------------------------------------------------
  # ○ 改ページ処理
  #--------------------------------------------------------------------------
  alias _wdtk_choice_new_page new_page
  def new_page(text, pos)
    _wdtk_choice_new_page(text, pos)
    reset_under_choice
  end
  #--------------------------------------------------------------------------
  # ● 選択肢をメッセージ下に表示する際のリセット
  #--------------------------------------------------------------------------
  def reset_under_choice
    if $game_message.under_choice
      $game_message.choice_x = self.x + 16 + new_line_x
      $game_message.choice_y = self.y
      $game_message.choice_row_max = visible_line_number
    end
  end
  #--------------------------------------------------------------------------
  # ● 文章の標示を強制クリア
  #--------------------------------------------------------------------------
  def force_clear
    @gold_window.close
    @fiber = nil
    close
    if WdTk.include?(:MesEff)
      @character_sprites.each do |sprite, params|
        next if params.empty?
        sprite.bitmap.clear
        sprite.visible = false
        params.clear
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 文章を最後まで表示する
  #--------------------------------------------------------------------------
  def on_show_fast
    @show_fast = true
  end
end