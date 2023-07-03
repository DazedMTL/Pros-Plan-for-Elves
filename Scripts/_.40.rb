#==============================================================================
# ★ RGSS3_ネームポップ Ver1.11
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

イベント名かイベント実行内容の先頭に『注釈』コマンドで
<namepop 文字列>
と記述してください。
イベントキャラクターの頭上に文字列が表示されます。

イベント名で指定した場合はイベント全ページに適用されますが、
優先度は注釈コマンドの方が高くなっています。

文字を消したい場合は <namepop none> としてください。

2014.11.12  Ver1.11
  ・イベントの一時消去などでネームポップが残る不具合を修正

2011.12.16  Ver1.1
  ・フォントの縁取り不透明度を設定項目に追加

2011.12.15  Ver1.0
  公開
 
=end

#==============================================================================
# □ 設定項目
#==============================================================================
module TMNPOP
  FONT_SIZE = 18          # フォントサイズ
  FONT_OUT_ALPHA = 255    # フォントの縁取り不透明度
end

#==============================================================================
# ■ Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :namepop                  # ポップアップテキスト
  #--------------------------------------------------------------------------
end

#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● イベントページの設定をクリア
  #--------------------------------------------------------------------------
  alias tmnpop_game_event_clear_page_settings clear_page_settings
  def clear_page_settings
    tmnpop_game_event_clear_page_settings
    @namepop = nil
  end
  #--------------------------------------------------------------------------
  # ● イベントページの設定をセットアップ
  #--------------------------------------------------------------------------
  alias tmnpop_game_event_setup_page_settings setup_page_settings
  def setup_page_settings
    tmnpop_game_event_setup_page_settings
    @namepop = nil
    if @list
      @namepop = $1 if /<namepop\s*(\S+?)>/i =~ @event.name
      @list.each do |list|
        if list.code == 108 || list.code == 408
          @namepop = $1 if /<namepop\s*(\S+?)>/i =~ list.parameters[0]
        else
          break
        end
      end
    end
  end
end

#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias tmnpop_sprite_character_dispose dispose
  def dispose
    dispose_namepop
    tmnpop_sprite_character_dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmnpop_sprite_character_update update
  def update
    tmnpop_sprite_character_update
    update_namepop
    if @character.namepop != @namepop
      @namepop = @character.namepop
      start_namepop
    end
  end
  #--------------------------------------------------------------------------
  # ○ namepopの開始
  #--------------------------------------------------------------------------
  def start_namepop
    dispose_namepop
    return if @namepop == "none" || @namepop == nil
    @namepop_sprite = ::Sprite.new(viewport)
    h = TMNPOP::FONT_SIZE + 4
    @namepop_sprite.bitmap = Bitmap.new(h * 10, h)
    @namepop_sprite.bitmap.font.size = TMNPOP::FONT_SIZE
    @namepop_sprite.bitmap.font.out_color.alpha = TMNPOP::FONT_OUT_ALPHA
    @namepop_sprite.bitmap.draw_text(0, 0, h * 10, h, @namepop, 1)
    @namepop_sprite.ox = h * 5
    @namepop_sprite.oy = h
    update_namepop
  end
  #--------------------------------------------------------------------------
  # ○ namepopの更新
  #--------------------------------------------------------------------------
  def update_namepop
    if @namepop_sprite
      @namepop_sprite.x = x
      @namepop_sprite.y = y - height
      @namepop_sprite.z = z + 200
    end
  end
  #--------------------------------------------------------------------------
  # ○ namepopの解放
  #--------------------------------------------------------------------------
  def dispose_namepop
    if @namepop_sprite
      @namepop_sprite.bitmap.dispose
      @namepop_sprite.dispose
      @namepop_sprite = nil
    end
  end
end

