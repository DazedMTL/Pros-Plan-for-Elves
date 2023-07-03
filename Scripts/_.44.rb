=begin
  #==============================================================================
  #  ■　カメラの移動を滑らかにするスクリプト ver1.03
  #==============================================================================
  # @author 村人A
  #------------------------------------------------------------------------------
  # @バージョン情報
  # 2018/01/08 ver1.03：キャラクターのアニメーション表示がずれてしまう不具合を
  #                     修正しました。
  # 2018/01/08 ver1.02：中心が少しずれてしまう点を修正しました。
  #                     解像度の変更に対応しました。
  # 2018/01/05 ver1.00：スクリプト配布開始
  #------------------------------------------------------------------------------
  # @help
  # イベントスクリプトにて
  # set_camera_speed(0.02)
  # などと記述すると滑らかカメラ移動がonになります。
  # ()内にはカメラがプレイヤーを追う速さの数値を入れてください。
  # 1で通常のスピードです。0.02くらいがいい感じのスクロールになります。
  # イベントコマンドでスクロールをする場合は一度set_camera_speed(1)にしてください。
  #==============================================================================
=end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

class Game_Player < Game_Character
  attr_accessor :is_move_scrolling             # マップスピード
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias villaA_scm_initialize initialize
  def initialize
    villaA_scm_initialize
    @is_move_scrolling = false
  end

  #--------------------------------------------------------------------------
  # ● スクロール処理
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    if $game_map.map_move_speed != 1
      adj_x = 0.5*(Graphics.width - 544)/32.to_f
      adj_y = 0.5*(Graphics.height - 416)/32.to_f
      ax1 = 8 + adj_x;
      ay1 = 6 + adj_y;
      if (ax2 - center_x).abs <= 0.1
        ax2 = center_x
        @is_move_scrolling = false
      else
        @is_move_scrolling = true
      end
      if (ay2 - center_y).abs <= 0.1
        ay2 = center_y
        @is_move_scrolling = false
      else
        @is_move_scrolling = true
      end
      $game_map.scroll_down (ay2 - ay1) if ay2 > center_y
      $game_map.scroll_left (ax1 - ax2) if ax2 < center_x
      $game_map.scroll_right(ax2 - ax1) if ax2 > center_x
      $game_map.scroll_up   (ay1 - ay2) if ay2 < center_y
    else
      $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
      $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
      $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
      $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
    end
  end
end

#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  attr_accessor :map_move_speed             # マップスピード
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias smooth_camera_initialize initialize
  def initialize
    smooth_camera_initialize
    @map_move_speed = 1
  end
  
  #--------------------------------------------------------------------------
  # ● 下にスクロール
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height
      @parallax_y += distance if @parallax_loop_y
    else
      last_y = @display_y
      @display_y = [@display_y + distance*$game_map.map_move_speed, height - screen_tile_y].min
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # ● 左にスクロール
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width - distance
      @display_x %= @map.width 
      @parallax_x -= distance if @parallax_loop_x
    else
      last_x = @display_x
      @display_x = [@display_x - distance*$game_map.map_move_speed, 0].max
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # ● 右にスクロール
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width
      @parallax_x += distance if @parallax_loop_x
    else
      last_x = @display_x
      @display_x = [@display_x + distance*$game_map.map_move_speed, (width - screen_tile_x)].min
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # ● 上にスクロール
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height - distance
      @display_y %= @map.height
      @parallax_y -= distance if @parallax_loop_y
    else
      last_y = @display_y
      @display_y = [@display_y - distance*$game_map.map_move_speed, 0].max
      @parallax_y += @display_y - last_y
    end
  end
end

#==============================================================================
# ■ Sprite_Base
#------------------------------------------------------------------------------
# 　アニメーションの表示処理を追加したスプライトのクラスです。
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias villaA_scm1_initialize initialize
  def initialize(viewport = nil)
    villaA_scm1_initialize(viewport)
    @animation_fix_pos = []
  end
  
  #--------------------------------------------------------------------------
  # ● アニメーションの原点設定
  #--------------------------------------------------------------------------
  def set_animation_origin
    if @animation.position == 3
      if viewport == nil
        @ani_ox = Graphics.width / 2
        @ani_oy = Graphics.height / 2
      else
        @ani_ox = viewport.rect.width / 2
        @ani_oy = viewport.rect.height / 2
      end
    else
      @ani_ox = x - ox + width / 2
      @ani_oy = y - oy + height / 2
      if @animation.position == 0
        @ani_oy -= height / 2
      elsif @animation.position == 2
        @ani_oy += height / 2
      end
    end
    @animation_fix_pos = [@ani_ox, @ani_oy]
  end
  
  #--------------------------------------------------------------------------
  # ● アニメーションスプライトの設定
  #     frame : フレームデータ（RPG::Animation::Frame）
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror
        sprite.x = @animation_fix_pos[0] - cell_data[i, 1]
        sprite.y = @animation_fix_pos[1] + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @animation_fix_pos[0] + cell_data[i, 1]
        sprite.y = @animation_fix_pos[1] + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
end

#==============================================================================
# ■ Sprite_Character
#------------------------------------------------------------------------------
# 　キャラクター表示用のスプライトです。Game_Character クラスのインスタンスを
# 監視し、スプライトの状態を自動的に変化させます。
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 新しいエフェクトの設定
  #--------------------------------------------------------------------------
  alias villaA_scm_setup_new_effect setup_new_effect
  def setup_new_effect
    return if $game_player.is_move_scrolling
    villaA_scm_setup_new_effect
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  def set_camera_speed(speed)
    $game_map.map_move_speed = speed
  end
end
