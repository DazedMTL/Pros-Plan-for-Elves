#==============================================================================
# RGSS3_ウインドウ色を味方敵で分ける ver1.01　10/18メモ取得不具合修正
# 2014/06/18公開
# 2014/06/25スクリプト整理
# C Winter (http://ccwinter.blog.fc2.com/)
#==============================================================================

=begin

「画面上部にスキル名表示1.08」拡張

ウインドウ色を「使用者が味方か敵か」で分ける


スキル・アイテムのメモ欄に
 <味方ウインドウ色=-34,0,68>
 <敵ウインドウ色=255,-255,-255>
のように書き込んで設定する


設定項目の ATTACK_MODE が true で通常攻撃の場合
  ウインドウ色はスキルID1の「攻撃」のメモ欄で設定したものになる
  元のように「武器ごと」「アクター・エネミーごと」に設定することはできない

スキル・アイテムの場合
  ウインドウ色はそのスキル・アイテムのメモ欄で設定したものになる

=end

#==============================================================================
# ■ 設定項目
#==============================================================================
module Top_Skill::AE_WindowColor
  
  # 通常攻撃のウインドウ色も味方敵で分けるか
  #   trueなら分ける   falseなら分けない（このスクリプトが入っていない時と同じ）
  ATTACK_MODE = true
  
  # メモ指定がない場合の　味方ウインドウ色
  DEFAULT_ACTOR_COLOR = [-34, 0, 68]
  
  # メモ指定がない場合の　　敵ウインドウ色
  DEFAULT_ENEMY_COLOR = [255, -255, -255]
  
end

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  def top_window_actor_color
    if @note =~ /<味方ウインドウ色=(\-*\d+),(\-*\d+),(\-*\d+)>/
      return Tone.new($1.to_i, $2.to_i, $3.to_i)
    else
      t = Top_Skill::AE_WindowColor::DEFAULT_ACTOR_COLOR
      return Tone.new(t[0], t[1], t[2])
    end
  end
  def top_window_enemy_color
    if @note =~ /<敵ウインドウ色=(\-*\d+),(\-*\d+),(\-*\d+)>/
      return Tone.new($1.to_i, $2.to_i, $3.to_i)
    else
      t = Top_Skill::AE_WindowColor::DEFAULT_ENEMY_COLOR
      return Tone.new(t[0], t[1], t[2])
    end
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● データ変換
  #--------------------------------------------------------------------------
  def convert_top_skill_data_ae_window_color(data, item, user)
    if item.is_a?(RPG::Skill) and item.id == 1  # 通常攻撃の場合
      return data unless Top_Skill::AE_WindowColor::ATTACK_MODE
    end
    actor_color = item.top_window_actor_color
    enemy_color = item.top_window_enemy_color
    data[3] = user.enemy? ? enemy_color : actor_color
    return data
  end
end