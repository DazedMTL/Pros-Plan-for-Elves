#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
#
#スイッチを使って、アイテムの使用可能判定をします。
#
#使い方
#アイテムのメモ欄に<ITEM_USE_SWITCH_n>(nはスイッチ番号）と書きます。
#そのスイッチがONの時、そのアイテムは使用出来ません。
#
#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

#--------------------------------------------------------------------------
# ★ システムワードの登録：使用可能にするスイッチの番号
#--------------------------------------------------------------------------
class RPG::BaseItem
  def item_use_switch
    /<ITEM_USE_SWITCH_(\d+)>/ =~ note ? $1.to_i : 828
  end
end


#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用可能判定
  #--------------------------------------------------------------------------
  def usable?(item)
    if item != nil
      if item.item_use_switch != 0
        return false if $game_switches[item.item_use_switch] == true
      end
    end
    return skill_conditions_met?(item) if item.is_a?(RPG::Skill)
    return item_conditions_met?(item)  if item.is_a?(RPG::Item)
    return false
  end
end
