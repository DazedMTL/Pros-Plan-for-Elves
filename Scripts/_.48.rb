=begin
　スキル・アイテム使用条件追加 for VX ace
  VARSION::0.0.0.2
  URL:: www.tktkgame.com

  
  アイテム、スキルのメモ欄にスイッチや変数の条件を書くことで
  使用条件を追加する

  例)変数1が２～４でかつスイッチ１がONのときのみ使用可能にする場合
  [使用条件:変数1 > 1]
  [使用条件:変数1 <= 4]
  [使用条件:スイッチ1 ON]
  
=end
module TkTkGame
end

module TkTkGame::AddItemUsableCondition
  REGEX_USEABLE_CONDITION = /\[(?:COND|CONDITION|使用条件):(.+?)\]/i
  REGEX_VAR_CONDITION = /(?:変数|VAR)(\d+)\s*(==|!=|>|>=|<|<=)\s*(\-?\d+)/i
  REGEX_SW_CONDITION  = /(?:スイッチ|SW)(\d+)\s*(ON|OFF)/i
  module ConditionType
    VAR = 1
    SW  = 2
  end
  module MixinUseableItem
    def tkgc_init_var_sw_condition
      @tkgc_var_sw_condition = []
      self.note.scan(REGEX_USEABLE_CONDITION) do |cm|
        params = cm[0]
        params.scan(REGEX_VAR_CONDITION) do |vm|
          if vm[0].to_i > 0
            @tkgc_var_sw_condition.push([ConditionType::VAR, vm[0].to_i,vm[1], vm[2].to_i])
          end
        end
        params.scan(REGEX_SW_CONDITION) do |sm|
          if sm[0].to_i > 0
            @tkgc_var_sw_condition.push([ConditionType::SW, sm[0].to_i,(sm[1].downcase == 'on')])
          end
        end
      end
    end
    
    def tkcg_var_sw_condition_met?
      self.tkgc_init_var_sw_condition() if @tkgc_var_sw_condition.nil?
      @tkgc_var_sw_condition.each do |c|
        if c[0] == ConditionType::VAR
          case c[2]
          when '=='
            return false unless ($game_variables[c[1]] == c[3])
          when '!='
            return false unless ($game_variables[c[1]] != c[3])
          when '>'
            return false unless ($game_variables[c[1]] >  c[3])
          when '>='
            return false unless ($game_variables[c[1]] >= c[3])
          when '<'
            return false unless ($game_variables[c[1]] <  c[3])
          when '<='
            return false unless ($game_variables[c[1]] <= c[3])
          end
        elsif c[0] == ConditionType::SW
          return false unless ($game_switches[c[1]] == c[2])
        end
      end
      return true
    end
    def battle_ok?
      return false unless self.tkcg_var_sw_condition_met?
      super
    end
    def menu_ok?
      return false unless self.tkcg_var_sw_condition_met?
      super
    end
  end
end

class RPG::Item
  include TkTkGame::AddItemUsableCondition::MixinUseableItem
end
class RPG::Skill
  include TkTkGame::AddItemUsableCondition::MixinUseableItem
end