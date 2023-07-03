#==============================================================================
# ■ RGSS3 画像キャッシュ削除スクリプト Ver1.00 by 星潟
#------------------------------------------------------------------------------
# ゲーム内でシーン移行時、及びマップ移動時に
# 保持している画像キャッシュデータを削除します。
# 特定のゲームスイッチがONの時だけ有効にすることもできます。
#
# また、キャッシュ保持数が一定以上を超えないように制限する事も出来ます。
#==============================================================================
module Cache_Delete
  
  #シーン移行時の削除用スイッチを指定します。
  #このスイッチがONの場合のみ、シーン移行時に画像キャッシュを削除します。
  #
  #問答無用で削除する場合はnilにして下さい。
  #機能を無効化する場合は0にして下さい。
  
  SWITCH1 = nil
  
  #マップ移動時の削除用スイッチを指定します。
  #このスイッチがONの場合のみ、マップ移動時に画像キャッシュを削除します。
  #
  #問答無用で削除する場合はnilにして下さい。
  #機能を無効化する場合は0にして下さい。
  
  SWITCH2 = nil
  
  #画像キャッシュ保持限界数を1以上の数で指定します。
  #画像キャッシュ保持限界数がここで指定した値を超えた場合
  #古いキャッシュから順次削除します。
  #
  #小さい数であればあるほど
  #キャッシュによるメモリ使用量が軽減されますが
  #その分、読み込み負荷が増大し
  #ゲームプレイに影響が出る恐れがあります。
  #
  #機能を無効化する場合は0にして下さい。
  
  MAXIMUM = 40
  
end
class << Cache
  alias load_bitmap_cache_reset load_bitmap
  def load_bitmap(folder_name, filename, hue = 0)
    cache_limit_check
    load_bitmap_cache_reset(folder_name, filename, hue)
  end
  def cache_limit_check
    @maximum = Cache_Delete::MAXIMUM if @maximum == nil
    return if @maximum == 0 or @cache == nil or @cache.size == 0
    return if @cache.size <= @maximum
    @cache.shift
  end
  def cache_size
    @cache.size
  end
end
class << SceneManager
  def delete_judge
    return true if Cache_Delete::SWITCH1 == nil
    return false if Cache_Delete::SWITCH1 == 0
    return true if $game_switches[Cache_Delete::SWITCH1]
    return false
  end
  #--------------------------------------------------------------------------
  # ● 直接遷移
  #--------------------------------------------------------------------------
  alias goto_cache_reset goto
  def goto(scene_class)
    Cache.clear if delete_judge
    goto_cache_reset(scene_class)
  end
  #--------------------------------------------------------------------------
  # ● 呼び出し
  #--------------------------------------------------------------------------
  alias call_cache_reset call
  def call(scene_class)
    Cache.clear if delete_judge
    call_cache_reset(scene_class)
  end
  #--------------------------------------------------------------------------
  # ● 呼び出し
  #--------------------------------------------------------------------------
  alias return_cache_reset return
  def return
    Cache.clear if delete_judge
    return_cache_reset
  end
end
class Game_Map
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias setup_cache_reset setup
  def setup(map_id)
    Cache.clear if delete_judge
    setup_cache_reset(map_id)
  end
  def delete_judge
    return true if Cache_Delete::SWITCH2 == nil
    return false if Cache_Delete::SWITCH2 == 0
    return true if $game_switches[Cache_Delete::SWITCH2]
    return false
  end
end