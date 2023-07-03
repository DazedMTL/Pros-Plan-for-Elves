#==============================================================================
# ■ ギャルゲー風ウィンドウ拡張4
#   @version 0.4 11/12/27 RGSS3
#   @author さば缶
#------------------------------------------------------------------------------
# 　ウィンドウの非表示とセーブ画面呼び出しが加わります
#==============================================================================
module Saba
  module GalEx
    # ウィンドウ非表示ボタン
    # 必要なければ nil を入れてください
    HIDE_BUTTON = Input::R
    
    # セーブボタン
    # 必要なければ nil を入れてください
    SAVE_BUTTON = nil
  end
end

class Scene_Map
  alias saba_hide_window_update update
  def update
    saba_hide_window_update
    return if @message_window.openness == 0
    if Input.trigger?(Saba::GalEx::HIDE_BUTTON)
      Sound.play_cursor
      @message_window.visible = ! @message_window.visible
    elsif Input.trigger?(Saba::GalEx::SAVE_BUTTON)
      if @message_window.is_a?(Window_MessageGal)
        Sound.play_cursor
        SceneManager.call(Scene_Save)
      end
    end
  end
end



class Window_MessageGal
  def visible=(v)
    super
    if v
      update_name_visibility
    else
      @name_sprite.visible = false
      @name_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● ふきだしの表示を切り替えます。
  #--------------------------------------------------------------------------
  alias saba_hide_window_update_balloon_visibility update_balloon_visibility
  def update_balloon_visibility
    unless self.visible
      @balloon_sprite.visible = false
      return
    end
    saba_hide_window_update_balloon_visibility
  end
end