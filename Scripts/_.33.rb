#==============================================================================
# ■ BMSP 行動前イベント[EVENTBOFOREACTION] Ver1.02 2014/05/25
#------------------------------------------------------------------------------
# 　戦闘中バトラーの行動直前にコモンイベントを実行できます．
#==============================================================================
#------------------------------------------------------------------------------
# ■内容
# 戦闘中バトラーの行動直前にコモンイベントを実行できます．
# これにより特定の条件下において発展するスキルや攻撃前のカットインなど
# 様々な機能を導入できます．
#
# 位置：特に指定はありません
#
# ■使用方法
# スクリプトに丸ごと貼り付けていただければ使用できます。
#
# ●コモンイベントの作成方法
# ・コモンイベントの名前
#   なんでも構いません．わかりやすい名前を付けて下さい
# ・トリガー
#   なし
# ・実行内容
#   一行目に注釈を作成してください．
#   内容は
#     ==行動前イベント:使用%display%==
#   と記述します．
#   %display%は「前」もしくは「後」で置き換えます．
#   前：スキル・アイテム使用前にコモンイベントを実行します
#   後：スキル・アイテム使用後(名前が表示され，MPなどが消費された直後)に
#       コモンイベントを実行します
#
#   二行目から注釈でないイベントコマンドまでは条件を表す注釈となります．
#   注釈1つにつき必ず満たすべき条件を書きます．
#   また，注釈内1行につきいづれかを満たせば良い条件を書きます．
#   例
#     注釈：条件1
#         ：条件2
#     注釈：条件3
#   この例では，条件1かつ条件3を満たすときまたは，
#   条件2かつ条件3を満たすときにこのイベントが実行されます．
#   条件以降については任意のイベントコマンドを並べることが出来ます．
#   例えば発展スキルなどの様な機能にするには戦闘行動の強制を利用します．
#   使用例
#     注釈：==行動前イベント:使用後==
#     注釈：use.id == 1
#     注釈：user.id == 1
#     注釈：targets.include?($game_troop.members[1])
#
# ●条件の書き方
# 条件部分はevalで評価しているのでrubyに書ける式を自由に書くことが出来ます．
# 特殊な変数として以下の3つがあります．
# ・use
#   使用するスキル・アイテムを参照できます．(RPG::Skill，RPG::Item)
# ・user
#   使用するアクター・エネミーを参照できます．(Game_Actor，Game_Enemy)
# ・targets
#   スキル・アイテムのターゲットとなるアクター・エネミーの配列です．
#   「使用後」のイベントでしか参照できません．
#   「使用前」のイベントでは空配列となります．
# useやuser，targetsから参照できる値や，
# その他の情報の参照についてはスクリプトエディタや
# ヘルプのVX Ace データ構造から各自が確認してください．
# 例：アクター001がスキル「防御」を使用したときに実行
#   注釈：user.id == 1
#   注釈：use.name == "防御"
# 例：アクター001またはアクター002がアイテムを使用したときに実行
#   注釈：user.id == 1
#       ：user.id == 2
#   注釈：use.is_a?(RPG::Item)
# 例：ターゲットにインデックス1のエネミーが含まれる場合に実行
#   注釈：targets.include?($game_troop.members[1])
# 例：スイッチ001がONで，所持金が変数001の値以上の時に実行
#   注釈：$game_switches[1] (わかりやすく書くと $game_switches[1] == true )
#   注釈：$game_party.gold >= $game_variables[1]
# 例：天候が雨の時に実行
#   注釈：$game_troop.screen.weather_type == :rain
# 
# もし条件の書き方がよくわからなければ掲示板(http://blueredzone.bbs.fc2.com/)
# あたりにでも書いて頂ければ条件式もお作りします．
#
# ちょっと応用した条件を書くことも・・・
# 例：ターゲットがスライムのみの場合実行
#   注釈：targets.size == 1 ? targets[0].original_name == "スライム" : false
#     以下はエラーになる可能性があるので注意！
#   注釈：targets.size == 1
#   注釈：targets[0].original_name == "スライム"
# 例：毎月7のつく日は実行
#   注釈：Time.now.day.to_s.include?("7")
# 例：パーティーの平均レベルが合計100以上
#   注釈：$game_party.members.inject{|sum, a| sum += a.level} >= 100
# 例：ローカル変数を使ったりもできる
#   注釈：a = 10; b = $game_variables[1]; a < b
#
# ■注意
# このスクリプトでは
# 「Scene_Battle」
# のメソッドを改変しています。
# ■情報
# このスクリプトはgentlawkによって作られたものです。
# 利用規約はhttp://blueredzone.comをご覧ください。
#------------------------------------------------------------------------------
module BMSP
  @@includes ||= {}
  @@includes[:EventBeforeAction] = 1.02
  module EventBeforeAction
    #--------------------------------------------------------------------------
    # ● 条件にマッチするコモンイベントを取得
    #--------------------------------------------------------------------------
    def self.commons(item, user, after_display, targets)
      return $data_common_events.select{ |ce|
        next false if ce.nil?
        check_condition(ce, item, user, after_display, targets)
      }
    end
    #--------------------------------------------------------------------------
    # ● 条件を満たすかチェック
    #--------------------------------------------------------------------------
    def self.check_condition(common_event, item, user, after_display, targets)
      list = common_event.list
      index = 0
      return false if list[index].code != 108 # 注釈じゃない
      define_comment = list[index].parameters[0]
      index += 1
      while list[index].code == 408
        index += 1
      end
      type = after_display ? "後" : "前"
      return false if define_comment != "==行動前イベント:使用#{type}=="
      # 条件文を抽出
      cond = []
      size = -1
      while list[index].code == 108
        size += 1
        cond[size] = [list[index].parameters[0]]
        index += 1
        while list[index].code == 408
          cond[size].push(list[index].parameters[0])
          index += 1
        end
      end
      return self.eval(cond, item, user, targets)
    end
    #--------------------------------------------------------------------------
    # ● 条件を評価
    #--------------------------------------------------------------------------
    def self.eval(formulas, use, user, targets)
      return formulas.inject(true){|ret, subformulas|
        ret && subformulas.inject(false){|r, formula|
          r || Kernel.eval(formula)
        }
      }
    end
  end
end
#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ● action_battlersに含まれるか
  #--------------------------------------------------------------------------
  def self.include_action_battlers?(battler)
    return @action_battlers.include?(battler)
  end
end
#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias bmsp_eventbeforeaction_update update
  def update
    catch(:bmsp_eventbeforeaction_abortjump){
      bmsp_eventbeforeaction_update
    }
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の処理
  #--------------------------------------------------------------------------
  alias bmsp_eventboforeaction_process_action process_action
  def process_action
    catch(:bmsp_eventbeforeaction_forced_action_self_jump){
      bmsp_eventboforeaction_process_action
    }
  end
  #--------------------------------------------------------------------------
  # ● 行動前前イベントの処理
  #--------------------------------------------------------------------------
  def bmsp_process_before_action_event(after_display,targets = [])
    item = @subject.current_action.item
    ces = BMSP::EventBeforeAction.commons(item, @subject, after_display, targets)
    ces.each do |ce|
      bmsp_execute_common_event(ce)
    end
  end
  #--------------------------------------------------------------------------
  # ● コモンイベントの実行
  #--------------------------------------------------------------------------
  def bmsp_execute_common_event(common_event)
    interpreter = Game_Interpreter.new
    interpreter.setup(common_event.list)
    loop do
      interpreter.update
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      BattleManager.judge_win_loss
      break unless interpreter.running?
      update_for_wait
      throw(:bmsp_eventbeforeaction_abortjump) if scene_changing?
    end
    # 自分の行動が強制されたら元の行動をカット
    unless @subject.current_action
      process_action_end
      throw(:bmsp_eventbeforeaction_forced_action_self_jump)
    end
    # 行動制約のあるステートが自分に付加されたら行動をカット
    unless @subject.movable?
      throw(:bmsp_eventbeforeaction_forced_action_invalid_action)
    end
    
    # 自分がパーティーから外れたら行動をカット
    if @subject.actor? and !$game_party.members.include?(@subject)
      @subject.clear_actions
      process_action_end
      throw(:bmsp_eventbeforeaction_forced_action_self_jump)
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行
  #--------------------------------------------------------------------------
  alias bmsp_eventbeforeaction_execute_action execute_action
  def execute_action
    catch(:bmsp_eventbeforeaction_forced_action_invalid_action){
      bmsp_process_before_action_event(false)
      @status_window.open
      bmsp_eventbeforeaction_execute_action
    }
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの表示
  #--------------------------------------------------------------------------
  alias bmsp_eventbeforeaction_show_animation show_animation
  def show_animation(targets, animation_id)
    bmsp_process_before_action_event(true,targets)
    refresh_status
    @status_window.open
    bmsp_eventbeforeaction_show_animation(targets, animation_id)
  end
end
						