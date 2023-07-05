#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab

  # ショップ画面
  ShopBuy         = "Buy"
  ShopSell        = "Sell"
  ShopCancel      = "Cancel"
  Possession      = "Items"

  # ステータス画面
  ExpTotal        = "Total EXP"
  ExpNext         = "Next"

  # セーブ／ロード画面
  SaveMessage     = "Which file would you like to save to?"
  LoadMessage     = "Which file would you like to load?"
  File            = "File"

  # 複数メンバーの場合の表示
  PartyName       = "%s"

  # 戦闘基本メッセージ
  Emerge          = "%s emerged！"
  Preemptive      = "%s ambushed the enemy！"
  Surprise        = "%s caught me off guard！"
  EscapeStart     = "%s ran away!"
  EscapeFailure   = "Failed to escape！"

  # 戦闘終了メッセージ
  Victory         = "%s was Victorious！"
  Defeat          = "%s was defeated..."
  ObtainExp       = "Obtained prostitute experience points for %s."
  ObtainGold      = "Obtained %s\\G of money."
  ObtainItem      = "Obtained %s."
  LevelUp         = "%s has become %s!"
  ObtainSkill     = "Learned %s!"

  # Item usage
  UseItem         = "%s used %s!"

  # Critical hit
  CriticalToEnemy = "Critical hit!!"
  CriticalToActor = "Powerful blow!!"

  # Action result on actor
  ActorDamage     = "%s depleted %s's HP!"
  ActorRecovery   = "%s's %s recovered by %s!"
  ActorGain       = "%s's %s increased by %s!"
  ActorLoss       = "%s's %s decreased by %s!"
  ActorDrain      = "%s had %s stolen by %s!"
  ActorNoDamage   = "%s's defense is too high to be damaged."
  ActorNoHit      = "Miss! %s is unaffected!"

  # Action result on enemy
  EnemyDamage     = "%s depleted %s's HP!"
  EnemyRecovery   = "%s's %s recovered by %s!"
  EnemyGain       = "%s's %s increased by %s!"
  EnemyLoss       = "%s's %s decreased by %s!"
  EnemyDrain      = "%s drained %s's %s!"
  EnemyNoDamage   = "%s can't be pleasured!"
  EnemyNoHit      = "Miss! %s can't be pleasured!"

  # Evasion / Reflection
  Evasion         = "%s dodged the attack!"
  MagicEvasion    = "%s cancelled out the magic!"
  MagicReflection = "%s reflected the magic!"
  CounterAttack   = "%s counterattacked!"
  Substitute      = "%s protected %s!"
  
  # Ability enhancement / debilitation
  BuffAdd         = "%s's %s increased!"
  DebuffAdd       = "%s's %s decreased!"
  BuffRemove      = "%s's %s returned to normal!"
  
  # Skill or item had no effect
  ActionFailure   = "No effect on %s!"
  
  # Error messages
  PlayerPosError  = "Player's initial position is not set."
  EventOverflow   = "Common event calls exceeded the limit."

  # 基本ステータス
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力値
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装備タイプ
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # コマンド
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 通貨単位
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # レベル
  def self.level_a;     basic(1);     end   # レベル (短)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (短)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (短)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (短)
  def self.fight;       command(0);   end   # 戦う
  def self.escape;      command(1);   end   # 逃げる
  def self.attack;      command(2);   end   # 攻撃
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # アイテム
  def self.skill;       command(5);   end   # スキル
  def self.equip;       command(6);   end   # 装備
  def self.status;      command(7);   end   # ステータス
  def self.formation;   command(8);   end   # 並び替え
  def self.save;        command(9);   end   # セーブ
  def self.game_end;    command(10);  end   # ゲーム終了
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 防具
  def self.key_item;    command(14);  end   # 大事なもの
  def self.equip2;      command(15);  end   # 装備変更
  def self.optimize;    command(16);  end   # 最強装備
  def self.clear;       command(17);  end   # 全て外す
  def self.new_game;    command(18);  end   # ニューゲーム
  def self.continue;    command(19);  end   # コンティニュー
  def self.shutdown;    command(20);  end   # シャットダウン
  def self.to_title;    command(21);  end   # タイトルへ
  def self.cancel;      command(22);  end   # やめる
  #--------------------------------------------------------------------------
end
