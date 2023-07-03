#==============================================================================
#
# ★ RGSS3_ターンの最初と最後にコモンイベント ver1.00
#
# 製作：ベザェルル
# http://bzallchiaki.ky-3.net/
# 戦闘ターンの最初と最後に設定したコモンイベントを実行します。
# 複数は無理なんで、コモンイベントのほうで呼び出してくだしあ！
# 　
#==============================================================================
#==============================================================================
# □ ↓↓↓設定項目
#==============================================================================
module BZATURNCOMMON
  $bza_turn_start_common_id = 1055     # ターン最初に発動するコモンイベントID
  $bza_turn_end_common_id =        # ターン最後に発動するコモンイベントID
  Bza_Turn_Start_Common = true      # ターン最初にコモンイベントを使用？
  Bza_Turn_End_Common = false        # ターン最後にコモンイベントを使用？
  Bza_Turn_Common_Priority = false  # 通常のバトルイベントより先に発動？
end
#==============================================================================
# □ ↑↑↑設定項目ここまで
#==============================================================================

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● ターン開始
  #--------------------------------------------------------------------------
  def turn_start
    @party_command_window.close
    @actor_command_window.close
    @status_window.unselect
    @subject =  nil
    BattleManager.turn_start
    @log_window.wait
    @log_window.clear
    $bza_ts_page_span = true if BZATURNCOMMON::Bza_Turn_Start_Common
  end
  #--------------------------------------------------------------------------
  # ● ターン終了
  #--------------------------------------------------------------------------
  def turn_end
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
    end
    BattleManager.turn_end
    $bza_te_page_span = true if BZATURNCOMMON::Bza_Turn_End_Common
    process_event
    start_party_command_selection
  end
end # class end

#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
class Game_Troop
  #--------------------------------------------------------------------------
  # ● バトルイベントのセットアップ
  #--------------------------------------------------------------------------
  def setup_battle_event
    return if @interpreter.running?
    return if @interpreter.setup_reserved_common_event
      if BZATURNCOMMON::Bza_Turn_Common_Priority
        if $bza_ts_page_span || $bza_te_page_span
          if $bza_ts_page_span
            event = $data_common_events[$bza_turn_start_common_id]
            @interpreter.setup(event.list)
            @event_flags[event] = true
            $bza_ts_page_span = false
            return
          end
          if $bza_te_page_span
            event = $data_common_events[$bza_turn_end_common_id]
            @interpreter.setup(event.list)
            @event_flags[event] = true
            $bza_te_page_span = false
            return
          end
        end
      end
    troop.pages.each do |page|
      if conditions_met?(page)
        @interpreter.setup(page.list)
        @event_flags[page] = true if page.span <= 1
        return
      end
    end
      if !BZATURNCOMMON::Bza_Turn_Common_Priority 
        if $bza_ts_page_span || $bza_te_page_span
          if $bza_ts_page_span
            event = $data_common_events[$bza_turn_start_common_id]
            @interpreter.setup(event.list)
            @event_flags[event] = true
            $bza_ts_page_span = false
            return
          end
          if $bza_te_page_span
            event = $data_common_events[$bza_turn_end_common_id]
            @interpreter.setup(event.list)
            @event_flags[event] = true
            $bza_te_page_span = false
            return
          end
        end
      end
    return
  end
end # class end