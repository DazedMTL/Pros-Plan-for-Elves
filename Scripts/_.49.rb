#==============================================================================
#                        アニメーション表示拡張
#==============================================================================
=begin
  機能
  カスタマイズで設定したスイッチが ON の時
  ピクチャの上に戦闘アニメーションを表示させることが出来ます

  再定義箇所
  Spriteset_Battle
  Sprite_Picture

  作成者: 浦島
  サイト: 浦島日記
  URL: http://urashima0401.blog.fc2.com/
  readmeやスタッフロールの明記、使用報告は任意
=end

module Switches
#==============================================================================
# カスタマイズ
#==============================================================================
  # スイッチID
  # ON の時、ピクチャより上にアニメーションが表示されます
  Key  =  900
#==============================================================================
# カスタマイズ
#==============================================================================
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ○ ピクチャスプライトの更新 ※ 再定義
  #--------------------------------------------------------------------------
  def update_pictures
    $game_troop.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)if !$game_switches[Switches::Key]
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport1, pic) if $game_switches[Switches::Key]
      @picture_sprites[pic.number].z = 250 if $game_switches[Switches::Key]
      @picture_sprites[pic.number].update
    end
  end
end

#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ○ ピクチャスプライトの更新 ※ 再定義
  #--------------------------------------------------------------------------
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)if !$game_switches[Switches::Key]
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport1, pic) if $game_switches[Switches::Key]
      @picture_sprites[pic.number].z = 250 if $game_switches[Switches::Key]
      @picture_sprites[pic.number].update
    end
  end
end

#==============================================================================
# ■ Sprite_Picture
#==============================================================================
class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # ○ 位置の更新 ※ 再定義
  #--------------------------------------------------------------------------
  def update_position
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number if !$game_switches[Switches::Key]
    self.z = 250 + @picture.number if $game_switches[Switches::Key]
  end
end