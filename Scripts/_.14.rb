# ★ RGSS3_メッセージ制御文字拡張 Ver1.2
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

メッセージの制御文字に以下を追加します
  ・\J[n]　…　n番のアクターの職業名を描画
  ・\K[n]　#==============================================================================
…　n番のアクターの二つ名を描画
  ・\T[n]　…　n番のアイテムのアイコンと名前を描画
  ・\W[n]　…　n番の武器のアイコンと名前を描画
  ・\A[n]　…　n番の防具のアイコンと名前を描画
  ・\S[n]　…　n番のスキルのアイコンと名前を描画
  
エネミーのドロップアイテム入手メッセージと、レベルアップ時の
スキル習得メッセージにアイコンを追加します
  
おまけとして、イベントコマンド『アイテムの増減』『武器の増減』
『防具の増減』が実行されたとき、自動的にアイコンつきの入手メッセージを
表示する機能を搭載しています。
フラグスイッチ（初期設定では９番）をオンにすると機能が有効になります。

使用するゲームスイッチ（初期設定）
  0009

2012.04.11  Ver1.2
  ・職業名を描画する \J[n] を追加
  
2011.12.16  Ver1.1
  ・二つ名を描画する \K[n] を追加
  ・存在しないIDを渡してもエラー落ちしないように修正
  
2011.12.15  Ver1.0
  公開

=end

#==============================================================================
# □ 設定項目
#==============================================================================
module TMECEX
  SW_AUTO_MESSAGE = 9       # 自動メッセージ利用フラグとして扱うスイッチ番号
end

#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの獲得と表示 【再定義】
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      case item
      when RPG::Item;   text = "\\T[#{item.id}]"
      when RPG::Weapon; text = "\\W[#{item.id}]"
      when RPG::Armor;  text = "\\A[#{item.id}]"
      end
      $game_message.add(sprintf(Vocab::ObtainItem, text))
    end
    wait_for_message
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor
  #--------------------------------------------------------------------------
  # ● レベルアップメッセージの表示 【再定義】
  #     new_skills : 新しく習得したスキルの配列
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    $game_message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab::ObtainSkill, "\\S[#{skill.id}]"))
    end
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● アイテムの増減
  #--------------------------------------------------------------------------
  alias tmecex_game_interpreter_command_126 command_126
  def command_126
    tmecex_game_interpreter_command_126
    value = operate_value(@params[1], @params[2], @params[3])
    if value > 0
      if $game_switches[TMECEX::SW_AUTO_MESSAGE] && !$game_party.in_battle
        $game_message.add(sprintf(Vocab::ObtainItem,
          "\\T[#{@params[0]}]#{value > 1 ? " #{value} 個" : ""}"))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 武器の増減
  #--------------------------------------------------------------------------
  alias tmecex_game_interpreter_command_127 command_127
  def command_127
    tmecex_game_interpreter_command_127
    value = operate_value(@params[1], @params[2], @params[3])
    if value > 0
      if $game_switches[TMECEX::SW_AUTO_MESSAGE] && !$game_party.in_battle
        $game_message.add(sprintf(Vocab::ObtainItem,
          "\\W[#{@params[0]}]#{value > 1 ? " #{value} 個" : ""}"))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 防具の増減
  #--------------------------------------------------------------------------
  alias tmecex_game_interpreter_command_128 command_128
  def command_128
    tmecex_game_interpreter_command_128
    value = operate_value(@params[1], @params[2], @params[3])
    if value > 0
      if $game_switches[TMECEX::SW_AUTO_MESSAGE] && !$game_party.in_battle
        $game_message.add(sprintf(Vocab::ObtainItem,
          "\\A[#{@params[0]}]#{value > 1 ? " #{value} 個" : ""}"))
      end
    end
  end
end

#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 制御文字の事前変換
  #    実際の描画を始める前に、原則として文字列に変わるものだけを置き換える。
  #    文字「\」はエスケープ文字（\e）に変換。
  #--------------------------------------------------------------------------
  alias tmecex_window_base_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = tmecex_window_base_convert_escape_characters(text)
    result.gsub!(/\eJ\[(\d+)\]/i) { actor_class_name($1.to_i) }
    result.gsub!(/\eK\[(\d+)\]/i) { actor_nickname($1.to_i) }
    result.gsub!(/\eT\[(\d+)\]/i) {
      item = $data_items[$1.to_i]
      item ? "\eI[#{item.icon_index}]#{item.name}" : ""
    }
    result.gsub!(/\eW\[(\d+)\]/i) {
      item = $data_weapons[$1.to_i]
      item ? "\eI[#{item.icon_index}]#{item.name}" : ""
    }
    result.gsub!(/\eA\[(\d+)\]/i) {
      item = $data_armors[$1.to_i]
      item ? "\eI[#{item.icon_index}]#{item.name}" : ""
    }
    result.gsub!(/\eS\[(\d+)\]/i) {
      skill = $data_skills[$1.to_i]
      skill ? "\eI[#{skill.icon_index}]#{skill.name}" : ""
    }
    result
  end
  #--------------------------------------------------------------------------
  # ○ アクター n 番の職業名を取得
  #--------------------------------------------------------------------------
  def actor_class_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.class.name : ""
  end
  #--------------------------------------------------------------------------
  # ○ アクター n 番の二つ名を取得
  #--------------------------------------------------------------------------
  def actor_nickname(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.nickname : ""
  end
end

