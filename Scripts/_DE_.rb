 
#==============================================================================
#                       「メニューDEコモン」(ACE) ver1.0
#   製作者：奈々（なな）
#   へぷたなすくろーる http://heptanas.mamagoto.com/
#
#   ◇使用規約
#   使用される場合はスクリプト作成者として「奈々」を明記して下さい。
#   このスクリプトを改変したり、改変したものを配布するなどは自由ですが
#   その場合も元のスクリプトの作成者として名前は載せて下さい。
#   その他、詳しい利用規約はブログを参照して下さい。
#
#------------------------------------------------------------------------------
#
#   メニューを開いたときと閉じたときにコモンイベントを起動できます。
#   メニュー画面だけでなく、アイテム画面や装備画面などにも設定可能です。
#   但し、当然ながら使えるイベントコマンドは限られています。
#   （メッセージ、ピクチャ、キャラクターなどはそもそも存在しないので）
#   
#   使い方は初期設定で、対応する項目にコモンイベントの番号を指定します。
#   マイナスの数を指定した場合は、「メニュー中１回起動」設定となります。
#   （メニューを閉じてマップ画面に戻るまでに、１回しか起動しない）
#   
#   メニュー画面終了時のみ、「メニュー中１回起動」は最初の１回ではなく
#   マップ画面に戻るときだけ（最後の１回）起動する設定です。
#   
#   メニュー画面は他の画面を開いたり閉じたりするたびに
#   終了と開始が行われますのでタイミングに注意して下さい。
#
#==============================================================================
#   ◇初期設定
module Nana_MenuDECommon
  
  MENU_S = 0        #メニュー画面開始時
  
  MENU_E = 50        #メニュー画面終了時

  ITEM_S = 0        #アイテム画面開始時
  
  ITEM_E = 0        #アイテム画面終了時

  SKILL_S = 0       #スキル画面開始時
  
  SKILL_E = 0       #スキル画面終了時

  EQUIP_S = 49       #装備画面開始時
  
  EQUIP_E = 0       #装備画面終了時

  STATUS_S = 0      #ステータス画面開始時

  STATUS_E = 0      #ステータス画面終了時
  
  SAVE_S = 0        #セーブ画面開始時
  
  SAVE_E = 0        #セーブ画面終了時

end
#==============================================================================

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    if Nana_MenuDECommon::MENU_S > 0
      common_event = $data_common_events[Nana_MenuDECommon::MENU_S]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::MENU_S < 0 && $game_system.nmdec_switchs[0] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::MENU_S)]
      $game_system.nmdec_switchs[0] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias nmdec_terminate terminate
  def terminate
    if Nana_MenuDECommon::MENU_E > 0
      common_event = $data_common_events[Nana_MenuDECommon::MENU_E]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::MENU_E < 0 && SceneManager.scene_is?(Scene_Map)
      common_event = $data_common_events[-(Nana_MenuDECommon::MENU_E)]
      $game_system.nmdec_switchs[1] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_terminate
  end
end

#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    if Nana_MenuDECommon::ITEM_S > 0
      common_event = $data_common_events[Nana_MenuDECommon::ITEM_S]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::ITEM_S < 0 && $game_system.nmdec_switchs[2] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::ITEM_S)]
      $game_system.nmdec_switchs[2] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias nmdec_terminate terminate
  def terminate
    if Nana_MenuDECommon::ITEM_E > 0
      common_event = $data_common_events[Nana_MenuDECommon::ITEM_E]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::ITEM_E < 0 && $game_system.nmdec_switchs[3] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::ITEM_E)]
      $game_system.nmdec_switchs[3] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_terminate
  end
end

#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　スキル画面の処理を行うクラスです。処理共通化の便宜上、スキルも「アイテム」
# として扱っています。
#==============================================================================

class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    if Nana_MenuDECommon::SKILL_S > 0
      common_event = $data_common_events[Nana_MenuDECommon::SKILL_S]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::SKILL_S < 0 && $game_system.nmdec_switchs[4] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::SKILL_S)]
      $game_system.nmdec_switchs[4] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias nmdec_terminate terminate
  def terminate
    if Nana_MenuDECommon::SKILL_E > 0
      common_event = $data_common_events[Nana_MenuDECommon::SKILL_E]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::SKILL_E < 0 && $game_system.nmdec_switchs[5] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::SKILL_E)]
      $game_system.nmdec_switchs[5] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_terminate
  end
end


#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    if Nana_MenuDECommon::EQUIP_S > 0
      common_event = $data_common_events[Nana_MenuDECommon::EQUIP_S]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::EQUIP_S < 0 && $game_system.nmdec_switchs[6] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::EQUIP_S)]
      $game_system.nmdec_switchs[6] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias nmdec_terminate terminate
  def terminate
    if Nana_MenuDECommon::EQUIP_E > 0
      common_event = $data_common_events[Nana_MenuDECommon::EQUIP_E]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::EQUIP_E < 0 && $game_system.nmdec_switchs[7] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::EQUIP_E)]
      $game_system.nmdec_switchs[7] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_terminate
  end
end


#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　ステータス画面の処理を行うクラスです。
#==============================================================================

class Scene_Status < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    if Nana_MenuDECommon::STATUS_S > 0
      common_event = $data_common_events[Nana_MenuDECommon::STATUS_S]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::STATUS_S < 0 && $game_system.nmdec_switchs[8] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::STATUS_S)]
      $game_system.nmdec_switchs[8] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias nmdec_terminate terminate
  def terminate
    if Nana_MenuDECommon::STATUS_E > 0
      common_event = $data_common_events[Nana_MenuDECommon::STATUS_E]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::STATUS_E < 0 && $game_system.nmdec_switchs[9] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::STATUS_E)]
      $game_system.nmdec_switchs[9] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_terminate
  end
end

#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　セーブ画面の処理を行うクラスです。
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    if Nana_MenuDECommon::SAVE_S > 0
      common_event = $data_common_events[Nana_MenuDECommon::SAVE_S]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::SAVE_S < 0 && $game_system.nmdec_switchs[10] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::SAVE_S)]
      $game_system.nmdec_switchs[10] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias nmdec_terminate terminate
  def terminate
    if Nana_MenuDECommon::SAVE_E > 0
      common_event = $data_common_events[Nana_MenuDECommon::SAVE_E]
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    if Nana_MenuDECommon::SAVE_E < 0 && $game_system.nmdec_switchs[11] == nil
      common_event = $data_common_events[-(Nana_MenuDECommon::SAVE_E)]
      $game_system.nmdec_switchs[11] = true
      @interpreter = Game_Interpreter.new
      @interpreter.setup(common_event.list, 0)
      @interpreter.update
    end
    nmdec_terminate
  end
end


#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :nmdec_switchs            # １回起動用の判定配列
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias nmdec_initialize initialize
  def initialize
    nmdec_initialize
    @nmdec_switchs = Array.new(12)
  end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias nmdec_start start
  def start
    nmdec_start
    $game_system.nmdec_switchs = Array.new(12)
  end
end
