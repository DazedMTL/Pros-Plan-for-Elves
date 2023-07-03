=begin
ＰＧツクールＶＸＡｃｅ用スクリプト素材
イベＲントの接触エリアを拡大

２０１２年４月０９日
tamuraさんは遊び足りない　製作
http://tamurarpgvx.blog137.fc2.com/

【概要】
イベントが「接触している」とみなす範囲を広げます。


【導入方法】
スクリプトエディタを開き、左のリストの一番下、「ここに追加」と書いてある部分の
下の空欄を選び、右クリック、「挿入」を選ぶ。
出来た空欄に、「名前」の所でファイル名を入れておくといい。
右に空白の領域に、このテキストファイル前文をコピーして貼り付け。


【使い方】
・あるイベントの「実行内容」に、イベントコマンド「注釈」で、
接触エリア;3
などと記述して下さい。
通常、イベントに衝突しないと、「プレーヤーと接触」「イベントと接触」の
イベントは動作しませんが、上記のように注釈をつける事によって、
注釈をつけたイベントから３マス離れたエリアに侵入すると、接しているとみなして
イベントが起動します。

・接触エリアに侵入するとすぐに開始するイベントは、注釈を付けたイベントの
　トリガーを「プレーヤーと接触」もしくは「イベントと接触」のどちらかにします。
　どちらでも働きは同じです。
・エリア内で決定ボタンを押すと始まるイベントの場合は、注釈を付けたイベントの
　トリガーを「決定ボタン」として下さい。

・エリアの形状を選べます。
接触エリア;3;1
で、エリアはダイヤモンド型でなく、正方形となります。
接触エリア;3;0
など、２番目を１以外にするか、あるいは記述しないと従来通りダイヤ型になります。

【改訂履歴】
2012.02.24　初回作成。
2012.02.25　場所移動に対応。
2012.03.01　エリアがマップの限界をはみ出してしまうとエラーを起こすのを修正。
2012.03.06　エリアの形状を、ダイヤモンド型か正方形か選べるようにした。
2012.03.20　正方形でないマップだと不具合が出る問題を修正。
            ひとつも機能しているイベントが無い場合にエラーが出る問題への予防。
2012.03.29　プライオリティが「通常キャラと同じ」以外でも機能するようにした。
2012.04.09　製作中にイベントを消去するとエラー落ちするのを修正。

=end
#==============================================================================
# ■ Tamura_Aria_Touch
#------------------------------------------------------------------------------
#   初期状態では、このスクリプトは動かないイベントにしか使えません。
#   イベントを動かしたい場合はIS_MOVE = true　として下さい。
#   ただし、処理が重くなるはずですので非推奨です。
#==============================================================================
module Tamura_Area_Touch
  IS_MOVE = true
end


#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　ダメージエリアの設定関数を呼び出します。
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh_area_touch
    refresh_area_touch_default
    $game_player.area_touch_reset #接触エリアのリセット。
  end
  alias :refresh_area_touch_default :refresh
  alias :refresh :refresh_area_touch
end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 接触エリアを再設定する。（イベントのページが変更された時など）
  #--------------------------------------------------------------------------
  def area_touch_reset
    $event_touch_area = []
    for i in 0 ... $game_map.width
      retu = []
      for j in 0 ... $game_map.height
        retu.push [nil , nil]
      end
      $event_touch_area.push retu
    end
    
    #今パーティがいるマップにおける、全てのイベントを調べ、
    #現在、機能しているイベントページから「注釈」を抜き出す。
    for i in 1 .. $game_map.events.size
      event = $game_map.events[i]
      next unless event
      list = $game_map.events[i].list
      next unless list
      for j in 0 ... list.size
        if list[j].code == 108 #「注釈」である。
          tyuusyaku = list[j].parameters[0]
          touch_area_rewrite(tyuusyaku , event)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 接触エリアのリセット
  #--------------------------------------------------------------------------
  def touch_area_rewrite(tyuusyaku , event)
    if /接触エリア/ =~ tyuusyaku
      str1 = tyuusyaku.scan(/接触エリア(\S+)/)
      str = str1[0][0].scan(/;(\d+)/)
      str.push [0] if str[1] == nil
      if str[1][0].to_i == 1 #正方形型
        w = str[0][0].to_i #範囲
        for x in ( event.x - w ) .. ( event.x + w )
          for y in  ( event.y - w ) .. ( event.y + w )
            if x < $game_map.width and y < $game_map.height
              #接触エリア
              $event_touch_area[x][y] = [event.x , event.y , event.trigger]
            end
          end
        end
      else
        w = str[0][0].to_i #範囲
        for x in ( event.x - w ) .. ( event.x + w )
          d = ( event.x - x ).abs #中心からの距離（絶対値）
          for y in  ( event.y - w + d ) .. ( event.y + w - d )
            if x < $game_map.width and y < $game_map.height
              #接触エリア
              $event_touch_area[x][y] = [event.x , event.y , event.trigger]
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンによるイベント起動判定
  #--------------------------------------------------------------------------
  def check_action_event_touch_area
    check_action_event_touch_area_default
    if $event_touch_area[$game_player.x][$game_player.y][0] != nil
      if $event_touch_area[$game_player.x][$game_player.y][2] == 0
        ex = $event_touch_area[$game_player.x][$game_player.y][0]
        ey = $event_touch_area[$game_player.x][$game_player.y][1]
        $game_player.start_map_event_all_pri(ex,ey,[0])
        #$game_player.start_map_event(ex,ey,[0], true)
      end
    end
  end
  alias :check_action_event_touch_area_default :check_action_event
  alias :check_action_event :check_action_event_touch_area
  #--------------------------------------------------------------------------
  # ● イベント起動 プライオリティは無視。
  #--------------------------------------------------------------------------
  def start_map_event_all_pri(x,y,triggers)
    $game_map.events_xy(x, y).each do |event|
      if event.trigger_in?(triggers)
        event.start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 場所移動の実行
  #--------------------------------------------------------------------------
  def perform_transfer_event_area
    perform_transfer_event_area_default
    $game_player.area_touch_reset
  end
  alias :perform_transfer_event_area_default :perform_transfer
  alias :perform_transfer :perform_transfer_event_area
end
  

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update_touch_area_sce_map
    update_touch_area_sce_map_default
    begin
      if $event_touch_area[$game_player.x][$game_player.y][0] != nil
        if $event_touch_area[$game_player.x][$game_player.y][2] == 1 or 2
          ex = $event_touch_area[$game_player.x][$game_player.y][0]
          ey = $event_touch_area[$game_player.x][$game_player.y][1]
          $game_player.start_map_event_all_pri(ex,ey,[1,2])
          #$game_player.start_map_event(ex,ey,[1,2], true)
        end
      end
    rescue
      $game_player.area_touch_reset
    end
    #接触エリアのリセット。動くイベントに対応の場合。
    $game_player.area_touch_reset if Tamura_Area_Touch::IS_MOVE
  end
  alias :update_touch_area_sce_map_default :update
  alias :update :update_touch_area_sce_map
end