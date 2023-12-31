#==============================================================================
# ■ Window_EquipCommand
#------------------------------------------------------------------------------
# 　スキル画面で、コマンド（装備変更、最強装備など）を選択するウィンドウです。
#==============================================================================

class Window_EquipCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::equip2,   :equip)
    add_command(Vocab::optimize, :optimize)
    add_command(Vocab::clear,    :clear)
  end
end
