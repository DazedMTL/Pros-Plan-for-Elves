#==============================================================================
# ■ RGSS3 天候「多様な光」 Ver2.01　by 星潟
#------------------------------------------------------------------------------
# 新天候を追加します。
# 呼び出すにはイベントコマンドのスクリプトを使用する必要があります
# screen.change_weather("star_w1xxyy", n, w)
# もしくはscreen.change_weather(:star_w1xxyy, n, w)
# xxの箇所は色の指定です。
# _a _b _c _d _e _f _g _h _i _jの何れかを入力して下さい。
# yyの箇所は光の移動方法の指定です。
# _0 _1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 _13の何れかを入力して下さい。
#
# ☆色
#
# _a 白
# _b 赤
# _c 青
# _d 黄
# _e 緑
# _f 紫
# _g 橙
# _h 黒
# _i 黒を除くランダム発光（常に変色）
# _j 黒を除くランダム発光（最初に色決定）
# 
# ☆移動方法
#
# _0 右下へ移動
# _1 左下へ移動
# _2 右へ移動
# _3 左へ移動
# _4 下へ移動
# _5 上へ移動
# _6 右へ移動しつつ少し上へ移動
# _7 左へ移動しつつ少し上へ移動
# _8 少し右へ移動しつつ上へ移動
# _9 少し左へ移動しつつ上へ移動
# _10 左へ移動しつつ少し下へ移動
# _11 右へ移動しつつ少し下へ移動
# _12 少し左へ移動しつつ下へ移動
# _13 少し右へ移動しつつ下へ移動
#
# なお、各個内のnの部分には強さ(1～9)、
# wの部分には完全に切り替わるまでのウェイト(0～無制限)を入力してください。
# 切り替わるまでウェイトにしたい場合は、先程、wの部分に入力したウェイトを
# 通常のウェイトとしてイベントコマンドとして実行すれば問題ありません。
# 
# 記入例
# 
# screen.change_weather("star_w1_a_0", 12, 60)
# 
# 白色の光が右下に移動する
# 
# screen.change_weather(:star_w1_i_9, 9, 0)
# 
# ランダムに輝く光が少し左へ移動しつつ上へ移動
# 
# Ver1.01  天候が正常にスクロールしない不具合を修正
# Ver1.02  説明文のミスを修正し、移動パターンを追加・修正しました。
#          以前のバージョンの多様な光天候の状態で
#          セーブを行ったセーブデータでは
#          正常に天候が発生しないかもしれませんのでご注意ください。
# Ver1.02a 説明文のミスを修正しました。
# Ver2.00 処理の全面的な見直しを行いました。
#==============================================================================
module Cache
  #--------------------------------------------------------------------------
  # 五色紙吹雪/プリズムレインのキャッシュ化
  #--------------------------------------------------------------------------
  def self.star_weather1(number)
    @cache ||= {}
    path = "Graphics/StarWeather1/" + number.to_s
    unless include?(path)
      @cache[path] = Bitmap.new(5, 5)
      colors = []
      case number / 2
      when 0;2.times {|i| colors.push(Color.new(255, 255, 255, 150 - 100 * i))}
      when 1;2.times {|i| colors.push(Color.new(255,   0,   0, 150 - 100 * i))}
      when 2;2.times {|i| colors.push(Color.new(  0,   0, 255, 150 - 100 * i))}
      when 3;2.times {|i| colors.push(Color.new(255, 255,   0, 150 - 100 * i))}
      when 4;2.times {|i| colors.push(Color.new(  0, 255,   0, 150 - 100 * i))}
      when 5;2.times {|i| colors.push(Color.new(255,   0, 255, 150 - 100 * i))}
      when 6;2.times {|i| colors.push(Color.new(255, 128,   0, 150 - 100 * i))}
      when 7;2.times {|i| colors.push(Color.new(  0,   0,   0, 150 - 100 * i))}
      end
      case number % 2
      when 0
        @cache[path].fill_rect(1, 2, 3, 1, colors[0])
        @cache[path].fill_rect(2, 1, 1, 3, colors[0])
        @cache[path].fill_rect(2, 0, 1, 1, colors[1])
        @cache[path].fill_rect(1, 1, 1, 1, colors[1])
        @cache[path].fill_rect(3, 1, 1, 1, colors[1])
        @cache[path].fill_rect(0, 2, 1, 1, colors[1])
        @cache[path].fill_rect(4, 2, 1, 1, colors[1])
        @cache[path].fill_rect(1, 3, 1, 1, colors[1])
        @cache[path].fill_rect(3, 3, 1, 1, colors[1])
        @cache[path].fill_rect(2, 4, 1, 1, colors[1])
      when 1
        @cache[path].fill_rect(1, 1, 1, 1, colors[0])
        @cache[path].fill_rect(1, 3, 1, 1, colors[0])
        @cache[path].fill_rect(2, 2, 1, 1, colors[0])
        @cache[path].fill_rect(3, 1, 1, 1, colors[0])
        @cache[path].fill_rect(3, 3, 1, 1, colors[0])
        @cache[path].fill_rect(0, 0, 2, 1, colors[1])
        @cache[path].fill_rect(3, 0, 2, 1, colors[1])
        @cache[path].fill_rect(0, 1, 1, 1, colors[1])
        @cache[path].fill_rect(2, 1, 1, 1, colors[1])
        @cache[path].fill_rect(4, 1, 1, 1, colors[1])
        @cache[path].fill_rect(1, 2, 1, 1, colors[1])
        @cache[path].fill_rect(3, 2, 1, 1, colors[1])
        @cache[path].fill_rect(0, 3, 1, 1, colors[1])
        @cache[path].fill_rect(2, 3, 1, 1, colors[1])
        @cache[path].fill_rect(4, 3, 1, 1, colors[1])
        @cache[path].fill_rect(0, 4, 2, 1, colors[1])
        @cache[path].fill_rect(3, 4, 2, 1, colors[1])
      end
    end
    @cache[path]
  end
end
class Game_Screen
  #--------------------------------------------------------------------------
  # 天候の変更
  #--------------------------------------------------------------------------
  alias change_weather_star_w1 change_weather
  def change_weather(type, power, duration)
    type = type.to_sym if type.to_s.include?("star_w1")
    change_weather_star_w1(type, power, duration)
  end
end
class Spriteset_Weather
  #--------------------------------------------------------------------------
  # 暗さの取得
  #--------------------------------------------------------------------------
  alias dimness_star_w1 dimness
  def dimness
    @type.to_s.include?("star_w1") ? 0 : dimness_star_w1
  end
  #--------------------------------------------------------------------------
  # 画面の更新
  #--------------------------------------------------------------------------
  alias update_screen_star_w1 update_screen
  def update_screen
    if @type.to_s.include?("star_w1")
      star_w1_change
    else
      @star_w1_flag = false
    end
    update_screen_star_w1
  end
  def star_w1_change
    @star_w1_flag = true
    if    @type.to_s.include?("_a");@star_w1_type = 0
    elsif @type.to_s.include?("_b");@star_w1_type = 1
    elsif @type.to_s.include?("_c");@star_w1_type = 2
    elsif @type.to_s.include?("_d");@star_w1_type = 3
    elsif @type.to_s.include?("_e");@star_w1_type = 4
    elsif @type.to_s.include?("_f");@star_w1_type = 5
    elsif @type.to_s.include?("_g");@star_w1_type = 6
    elsif @type.to_s.include?("_h");@star_w1_type = 7
    elsif @type.to_s.include?("_i");@star_w1_type = 8
    elsif @type.to_s.include?("_j");@star_w1_type = 9
    end
    if    @type.to_s.include?("_10");@star_w1_array = [-2, 1]
    elsif @type.to_s.include?("_11");@star_w1_array = [ 2, 1]
    elsif @type.to_s.include?("_12");@star_w1_array = [-1, 2]
    elsif @type.to_s.include?("_13");@star_w1_array = [ 1, 2]
    elsif @type.to_s.include?("_0") ;@star_w1_array = [ 1, 1]
    elsif @type.to_s.include?("_1") ;@star_w1_array = [-1, 1]
    elsif @type.to_s.include?("_2") ;@star_w1_array = [ 1, 0]
    elsif @type.to_s.include?("_3") ;@star_w1_array = [-1, 0]
    elsif @type.to_s.include?("_4") ;@star_w1_array = [ 0, 1]
    elsif @type.to_s.include?("_5") ;@star_w1_array = [ 0,-1]
    elsif @type.to_s.include?("_6") ;@star_w1_array = [-2,-1]
    elsif @type.to_s.include?("_7") ;@star_w1_array = [ 2,-1]
    elsif @type.to_s.include?("_8") ;@star_w1_array = [-1,-2]
    elsif @type.to_s.include?("_9") ;@star_w1_array = [ 1,-2]
    end
  end
  #--------------------------------------------------------------------------
  # フレーム更新
  #--------------------------------------------------------------------------
  alias update_sprite_star_w1 update_sprite
  def update_sprite(sprite)
    return update_sprite_star_w1(sprite) unless @star_w1_flag
    sprite.ox = @ox
    sprite.oy = @oy
    case @star_w1_type
    when 0..7
      sprite.bitmap = Cache.star_weather1(@star_w1_type * 2 + rand(2))
    when 8
      sprite.bitmap = Cache.star_weather1(rand(14))
    when 9
      @ex_w_count ||= rand(14)
      @ex_w_count = @ex_w_count % 2 == 0 ? @ex_w_count + 1 : @ex_w_count - 1
      sprite.bitmap = Cache.star_weather1(@ex_w_count)
    end
    sprite.opacity -= 12
    sprite.x += @star_w1_array[0]
    sprite.y += @star_w1_array[1]
    if sprite.opacity < 64
      @ex_w_count = rand(7) * 2
      sprite.bitmap = Cache.star_weather1(rand(7) * 2 + rand(2)) if @star_w1_type == 9
      data = rand(50) * 0.01
      sprite.zoom_x = 1 + data
      sprite.zoom_y = 1 + data
      create_new_particle(sprite)
      sprite.opacity = 255
    end
  end
end