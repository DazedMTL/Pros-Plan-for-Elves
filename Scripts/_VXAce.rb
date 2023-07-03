#==============================================================================
# ■ 経路探索VXAce (VX Ace用)
#------------------------------------------------------------------------------
# 製作者     : CanariAlternate
# サイト名   : カルトの鳥篭
# サイトURL  : http://canarialt.blog.fc2.com
#------------------------------------------------------------------------------
# ■ 概要 : 指定した座標(またはキャラクター)まで経路探索をしながら移動する。
#           この経路探索では一定時間動いていないイベントは障害物として認識する。
#
# ■ 必須 : 「注釈取得スクリプト」
#
# ■ 位置 : 「注釈取得スクリプト」より下
#           「マルチレイヤーシステム」より下
#------------------------------------------------------------------------------
# ■ 機能 : 1. 指定した座標(またはキャラクター)まで移動する。
#
#           2. 経路探索の移動で進入禁止の領域をリージョンIDで指定する。
#
#           3. 注釈にキーワードを記述すると経路探索において障害物と見なさない。
#
# ■ スクリプト(移動ルートの設定) : 
#           1. route_search(引数)
#              目標に到達するまで移動を繰り返す。
#              移動ルートの設定の「移動できない場合は飛ばす」は route_search には無効である。
#              引数はハッシュで設定する。省略するとあらかじめ設定されている初期値が採用される。
#              a. 目標の設定(※初期値はプレイヤー)
#                 :x => x座標
#                 :y => y座標
#                 :z => z座標(通常は使用しないので省略可能)
#                 :char_id => イベントID
#                 :character => オブジェクト($game_playerなど)
#
#                 指定する方法は以下の３通りである。
#                 :x, :y, :z は座標で指定する。:x と :y の両方設定しないと無効になる。
#                 :char_id はイベントのIDで指定する。プレイヤーを指定したい場合は -1 である。
#                 :character はオブジェクトを直接指定する。
#                 例1 route_search(:x => 5, :y => 7)             座標(5, 7)が目標
#                 例2 route_search(:char_id => 5)                イベントIDが５番のイベントが目標
#                 例3 route_search(:character => $game_player)   プレイヤーが目標
#
#              b. 斜め移動の使用(※初期値はfalse)
#                 :diagonal => true / false
#                 true  は斜め移動を使用する。
#                 false は斜め移動を使用しない。
#
#              c. 探索失敗時の行動(※初期値はtrue)
#                 :fail => true / false
#                 true  は失敗時はランダムに移動する。
#                 false は失敗時はウェイトする。
#
#              d. 経路探索を実行する目標との距離(※初期値は25)
#                 :length => 数値
#                 設定した数値より目標が遠い場合はウェイトする。
#
#              e. ウェイトの時間(※初期値は6)
#                 :wait => フレーム数
#                 false を設定するとウェイトせずに経路探索を中止する。
#
#              f. 目標の何歩前まで移動するか(※初期値は0)
#                 :near => 数値
#                 例えば、1 の場合は目標の１歩手前で探索終了する。
#                 0 であれば目標と重なるまで探索を終了しない。
#
#              g. 探索回数の上限(※初期値はfalse)
#                 :give_up => 数値
#                 false を設定すると自動モードになる。
#                 大きな数値(およそ100以上)を設定すると遠くまで探索するがPCへの負荷も大きくなる。
#
#              h. １回移動したら次の命令を実行(※初期値はfalse)
#                 :manual => true / false
#                 true  は１回移動すると次の命令を実行します。
#                 false は目標への移動が完了するまで移動を続けます。
#
#              i. 進入禁止のリージョンIDを設定(※初期値はこの下で設定)
#                 :region => [5, 6, 7]
#                 リージョンIDは配列で設定する必要がある。
#
#              これらの引数は全て省略可能で route_search と記述するだけでもプレイヤーを追尾する。
#------------------------------------------------------------------------------
# 更新履歴 : 2013/01/05 Ver2.05 スクリプトを大幅に変更した。スクリプト名を変更した。
#            2013/01/09 Ver3.05 内部処理を大幅に変更した。
#            2013/02/19 Ver3.06 共通処理スクリプトの廃止による変更を施した。
#            2013/06/28 Ver3.07 失敗時のランダム移動のバグを修正した。
#            2013/06/28 Ver3.08 斜め移動では[経路探索で無視]を無効にするように変更した。
#            2013/06/29 Ver3.09 ある条件を満たすと経路情報を捨てる機能を廃止した。
#            2013/06/29 Ver3.10 １回移動したら次の命令を実行するオプションを追加した。
#            2013/06/29 Ver3.11 ループしたマップで正常に移動しないバグを修正した。
#            2013/08/18 Ver3.12 進入禁止のリージョンIDを個別に設定できる機能を追加した。
#==============================================================================

$imported ||= {}
$imported[:CanariAlternate_RouteSearch] = true

#==============================================================================
# ■ Calt
#------------------------------------------------------------------------------
# 　CanariAlternateが製作したスクリプト用のモジュールです。
#==============================================================================
module Calt
  #-----------------------------------------------------------------------------
  # ◆経路探索で進入禁止にするリージョンIDの配列(引数を省略した際に適用される設定)
  NOT_ENTER_REGION_ID = [55]
  #
  # ◆イベントを障害物として扱わないことを設定するキーワード
  SCAN_THROUGH_EVENT_NOTE = /\[経路探索で無視\]/ # 記述した頁に適用
  SCAN_THROUGH_WHOLE_NOTE = /\<経路探索で無視\>/ # 全ての頁に適用(1頁目に記述)
  #-----------------------------------------------------------------------------
end

#==============================================================================
# ■ 探索処理 ■
#==============================================================================
#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
# 　主に移動ルートなどの処理を追加したキャラクターのクラスです。Game_Player、
# Game_Follower、GameVehicle、Game_Event のスーパークラスとして使用されます。
#==============================================================================
class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  LongSearchRate = 0.1                    # 探索回数の自動設定で長距離探索する確率
  #--------------------------------------------------------------------------
  # ● クラス変数
  #--------------------------------------------------------------------------
  @@route_search_frame = 0                # 経路探索を実行したフレームを記憶
  @@give_up_rate       = LongSearchRate   # 長距離探索を実行する確率
  #--------------------------------------------------------------------------
  # ● 経路探索で移動 [新規]
  #--------------------------------------------------------------------------
  def route_search(argument={})
    # パラメータの取得
    gx, gy, gz = get_goal_coordinate(argument)                          # 目的地(対象)の座標を取得
    diagonal = argument[:diagonal] != nil ? argument[:diagonal] : false # 斜め移動の使用の有無
    length   = argument[:length]   != nil ? argument[:length]   : 25    # 探索を実行する対象との距離
    wait     = argument[:wait]     != nil ? argument[:wait]     : 6     # ウェイト時間(false は待機せず探索中止)
    near     = argument[:near]     != nil ? argument[:near]     : 0     # 対象の何歩手前で停止するか
    fail     = argument[:fail]     != nil ? argument[:fail]     : true  # 探索失敗時に適当な移動を行うか
    give_up  = argument[:give_up]  != nil ? argument[:give_up]  : false # 探索回数の上限(false は自動)
    manual   = argument[:manual]   != nil ? argument[:manual]   : false # １回移動したら次の命令を実行
    region   = argument[:region]   != nil ? argument[:region]   : Calt::NOT_ENTER_REGION_ID # 進入禁止のリージョンIDの配列

    # 経路探索の設定
    @routing_object ||= Route_Search.new(self)                          # 経路探索のクラスのオブジェクトを生成
    @routing_object.not_enter_region_id     = region                    # 進入禁止のリージョンIDの配列を設定
    @routing_object.limit_search_count      = get_give_up(give_up)      # 探索回数の上限を設定
    @routing_object.always_collide_through  = false                     # 常に衝突判定無視を無効に設定
    @routing_object.ending_collide_distance = near != 0 ? near - 1 : 0  # 終点付近で衝突判定無視の距離を設定
    @routing_object.ending_through_distance = near - 1                  # 終点付近で通行判定無視の距離を設定
    @routing_object.diagonal                = diagonal                  # 斜め移動の使用の有無を設定
    @routing_object.active_collide_through  = 60                        # 指定フレーム以内に移動してるキャラクターは衝突判定無視を設定

    # 探索実行範囲内か判定
    distance = @routing_object.distance_xy(@x, @y, gx, gy)              # 終点までの最短距離を取得
    return wait_search(wait, manual) if distance > length               # 探索範囲外の場合はウェイト

    # 探索成功範囲内か判定
    if distance <= near && !(gx == @x && gy == @y && gz != z)           # 探索成功の場合
      return end_route_search                                           # 経路探索終了の手続きを実行
    end

    last_x, last_y, last_z = @x, @y, z                                  # 現在の座標を記憶
    last_route_list = @route_list                                       # 現在の経路情報を記憶
    
    # 通常の経路探索
    @route_list = @routing_object.a_star_search(gx, gy, gz)             # 経路情報の取得
    if !@route_list || @route_list.empty?                               # 経路情報を取得できなかった場合
      @route_list = nil                                                 # 経路情報を消去
      return wait_search(wait, manual) unless fail                      # 失敗時にランダム移動しない場合はウェイト
      fail_move_random(diagonal, region)                                # 失敗した場合の移動
      set_move_succeed(wait, last_x, last_y, last_z)                    # 移動成功を判定
      continue_route_search unless manual                               # 経路探索継続の手続きを実行
      return
    end
    if @route_list[0] == [gx, gy, gz]                                   # 終点までの経路情報の取得に成功した場合
      route_list_to_move(@route_list)                                   # 経路に従って移動
      set_move_succeed(wait, last_x, last_y, last_z)                    # 移動成功を判定
      continue_route_search unless manual                               # 経路探索継続の手続きを実行
      return
    end

    # 以前の経路情報を使用して経路探索
    new_route_list = @route_list                                        # 最新の推定経路情報を記憶
    @routing_object.limit_search_count = get_give_up(give_up)           # 探索回数の上限を設定
    @route_list = @routing_object.reuse_route_list(last_route_list, 5, gx, gy, gz)  # 以前の経路情報を使って探索
    if !@route_list || @route_list.empty?                               # 経路情報を取得できなかった場合
      @route_list = nil                                                 # 経路情報を消去
      return wait_search(wait, manual) unless fail                      # 失敗時に移動しない場合はウェイト
      @route_list = new_route_list                                      # 最新の推定経路情報を復帰
      route_list_to_move(@route_list)                                   # 経路に従って移動
      set_move_succeed(wait, last_x, last_y, last_z)                    # 移動成功を判定
      continue_route_search unless manual                               # 経路探索継続の手続きを実行
      return
    end
    if @route_list[0] == [gx, gy, gz]                                   # 終点までの経路情報の取得に成功した場合
      route_list_to_move(@route_list)                                   # 経路に従って移動
      set_move_succeed(wait, last_x, last_y, last_z)                    # 移動成功を判定
      continue_route_search unless manual                               # 経路探索継続の手続きを実行
      return
    end
    unless fail                                                         # 失敗時に移動しない場合
      @route_list = nil                                                 # 経路情報を消去
      wait_search(wait, manual)                                         # ウェイト
      return
    end
    old_x = @route_list[0][0]
    old_y = @route_list[0][1]
    old_distance = @routing_object.distance_xy(old_x, old_y, gx, gy)    # 更新推定経路の終点までの最短距離を取得
    new_x = new_route_list[0][0]
    new_y = new_route_list[0][1]
    new_distance = @routing_object.distance_xy(new_x, new_y, gx, gy)    # 最新推定経路の終点までの最短距離を取得
    @route_list = new_route_list if old_distance >= new_distance        # 最新推定経路の方が優れている場合は経路情報を復帰
    route_list_to_move(@route_list)                                     # 経路に従って移動
    set_move_succeed(wait, last_x, last_y, last_z)                      # 移動成功を判定
    continue_route_search unless manual                                 # 経路探索継続の手続きを実行
    return
  end
  #--------------------------------------------------------------------------
  # ● 対象の座標を取得 [新規]
  #--------------------------------------------------------------------------
  def get_goal_coordinate(argument)
    if argument[:x] && argument[:y]           # 座標で直接指定の場合
      return [argument[:x], argument[:y], argument[:z] || 0]
    end
    character = argument[:char]               # キャラクターのオブジェクトを直接指定
    if !character && id = argument[:char_id]  # キャラクターのIDで指定の場合
      character = case id
      when 0 ; self                           # id : 0  はこのキャラクター自体
      when -1; $game_player                   # id : -1 はプレイヤー
      else   ; $game_map.events[id] || self   # それ以外はイベント
      end
    else
      character = $game_player                # 指定が無い場合はプレイヤー
    end
    return [character.x, character.y, character.z]
  end
  #--------------------------------------------------------------------------
  # ● 経路探索を待機 [新規]
  #--------------------------------------------------------------------------
  def wait_search(wait, manual)
    if wait
      @wait_count = wait      # ウェイトを設定
      manual ? end_route_search : continue_route_search
    else
      @wait_count = 0         # ウェイトはなし
      end_route_search
    end
  end
  #--------------------------------------------------------------------------
  # ● 経路探索による移動を終了の手続き [新規]
  #--------------------------------------------------------------------------
  def end_route_search
    @move_succeed = true
  end
  #--------------------------------------------------------------------------
  # ● 経路探索による移動を継続の手続き [新規]
  #--------------------------------------------------------------------------
  def continue_route_search
    @move_succeed = true
    @move_route_index -= 1  # もう１度実行されるように実行位置を１つ戻す
  end
  #--------------------------------------------------------------------------
  # ● 経路リストに従って移動 [新規]
  #--------------------------------------------------------------------------
  def route_list_to_move(route_list)
    dx = distance_x_from(route_list[-1][0])
    dy = distance_y_from(route_list[-1][1])
    if dx == 0
      dy == 0 ? nil              : (dy < 0 ? move_straight(2)    : move_straight(8)   )
    elsif dx < 0
      dy == 0 ? move_straight(6) : (dy < 0 ? move_diagonal(6, 2) : move_diagonal(6, 8))
    else
      dy == 0 ? move_straight(4) : (dy < 0 ? move_diagonal(4, 2) : move_diagonal(4, 8))
    end
  end
  #--------------------------------------------------------------------------
  # ● 移動成功を判定 [新規]
  #--------------------------------------------------------------------------
  def set_move_succeed(wait, last_x, last_y, last_z)
    if last_x != @x || last_y != @y || last_z != z
      @move_succeed = true                                      # 移動成功
    else
      @move_succeed = false                                     # 移動失敗
      @wait_count = (wait || 6)                                 # 過負荷を回避する為にウェイト
      @route_list.push [@x, @y, z] if @route_list               # 経路情報を修正
    end
  end
  #--------------------------------------------------------------------------
  # ● 負荷を考慮した探索回数の上限値を取得 [新規]
  #--------------------------------------------------------------------------
  def get_give_up(give_up)
    return give_up if give_up
    if @@route_search_frame != Graphics.frame_count
      @@give_up_rate = LongSearchRate                           # 確率を初期化
      @@route_search_frame = Graphics.frame_count               # フレームの記憶を更新
    end
    if rand(10000) < 10000 * @@give_up_rate
      @@give_up_rate = 0                                        # 確率を更新
      result = 10 + rand(140)                                   # 高い上限を設定
    else
      @@give_up_rate *= @@give_up_rate / (1.0 - @@give_up_rate) # 確率を更新
      result = 10                                               # 低い上限を設定
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 失敗した場合の移動 [新規]
  #--------------------------------------------------------------------------
  def fail_move_random(diagonal, region)
    # 斜め移動の場合
    if diagonal && rand(2) == 0
      horz = rand(2) == 0 ? 4 : 6
      vert = rand(2) == 0 ? 2 : 8
      nx = $game_map.round_x_with_direction(@x, horz)
      ny = $game_map.round_y_with_direction(@y, vert)
      return if region.include?($game_map.region_id(nx, ny))
      move_diagonal(horz, vert)
      return
    end
    # ４方向移動の場合
    if rand(2) == 0
      horz = rand(2) == 0 ? 4 : 6
      nx = $game_map.round_x_with_direction(@x, horz)
      return if region.include?($game_map.region_id(nx, @y))
      move_straight(horz)
    else
      vert = rand(2) == 0 ? 2 : 8
      ny = $game_map.round_y_with_direction(@y, vert)
      return if region.include?($game_map.region_id(@x, ny))
      move_straight(vert)
    end
  end
end

#==============================================================================
# ■ 基礎定義 ■
#==============================================================================
#==============================================================================
# ■ Game_CharacterBase
#------------------------------------------------------------------------------
# 　キャラクターを扱う基本のクラスです。全てのキャラクターに共通する、座標やグ
# ラフィックなどの基本的な情報を保持します。
#==============================================================================
class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● クラス変数
  #--------------------------------------------------------------------------
  @@active_collide_through = false        # 座標一致判定の無効化
  @@collide_through        = false        # 衝突判定無視
  @@search_diagonal        = false        # 斜めの移動判定か否か
  def active_collide_through=(arg) ; @@active_collide_through = arg ; end
  def collide_through=(arg)        ; @@collide_through        = arg ; end
  def search_diagonal=(arg)        ; @@search_diagonal        = arg ; end
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :stopwatch                # 連続停止時間
  #--------------------------------------------------------------------------
  # ● z 座標の取得 [新規]
  #--------------------------------------------------------------------------
  def z
    return 0                              # 座標が３次元の場合は再定義する
  end
  #--------------------------------------------------------------------------
  # ● 公開メンバ変数の初期化 [追加]
  #--------------------------------------------------------------------------
  alias init_public_members_RouteSearch init_public_members
  def init_public_members
    init_public_members_RouteSearch
    @stopwatch = 1.0/0                    # 1.0/0 #=> Infinity
    @movement_record = [[nil, nil, nil]]  # 移動履歴
  end
  #--------------------------------------------------------------------------
  # ● 非公開メンバ変数の初期化 [追加]
  #--------------------------------------------------------------------------
  alias init_private_members_RouteSearch init_private_members
  def init_private_members
    init_private_members_RouteSearch
    @scan_through_event = false           # 経路探索において障害物として扱わないフラグ
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 [追加]
  #--------------------------------------------------------------------------
  alias update_RouteSearch update
  def update
    update_RouteSearch
    update_stopwatch                      # 連続停止時間を更新
  end
  #--------------------------------------------------------------------------
  # ● 連続停止時間を更新 [新規]
  #--------------------------------------------------------------------------
  def update_stopwatch
    if @movement_record[-1] != [x, y, z]
      @stopwatch = 0 if @movement_record.size > 1
      @movement_record.push [x, y, z]
      @movement_record.shift if @movement_record.size > 10
    elsif !moving?
      @stopwatch += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 座標一致判定 [追加]
  #--------------------------------------------------------------------------
  alias pos_RouteSearch? pos?
  def pos?(*args)
    return false if @@collide_through and !tile? || @scan_through_event && !@@search_diagonal
    # 連続停止時間が指定値以下の場合は座標を不一致にすることで衝突判定を回避する。
    return false if @@active_collide_through and @stopwatch <= @@active_collide_through && !tile? || @scan_through_event && !@@search_diagonal
    pos_RouteSearch?(*args)
  end
end
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 衝突判定無視の設定を取得 [新規]
  #--------------------------------------------------------------------------
  def get_scan_through_event_note
    event_result = event_note_include?(Calt::SCAN_THROUGH_EVENT_NOTE)
    whole_result = whole_note_include?(Calt::SCAN_THROUGH_WHOLE_NOTE)
    return event_result ^ whole_result
  end
  #--------------------------------------------------------------------------
  # ● イベントページ更新時に注釈から設定を取得 [追加]
  #--------------------------------------------------------------------------
  alias setup_note_settings_RouteSearch setup_note_settings
  def setup_note_settings
    setup_note_settings_RouteSearch
    @scan_through_event = get_scan_through_event_note
  end
end
#==============================================================================
# ■ Route_Search
#------------------------------------------------------------------------------
# 　経路探索の処理を定義したクラスです。
#==============================================================================
class Route_Search
  #--------------------------------------------------------------------------
  # ● 基礎変数の初期化
  #--------------------------------------------------------------------------
  def init_base_instance(character)
    @character = character                # キャラクターへの参照
    @x , @y , @z  = 0, 0, 0               # 今のノードの座標
    @sx, @sy, @sz = 0, 0, 0               # 始点の座標
    @gx, @gy, @gz = 0, 0, 0               # 終点の座標
    @diagonal = false                     # 斜め移動の使用の有無
    @collide_through = false              # 衝突判定を無視するフラグ
    @active_collide_through = 60          # 指定フレーム以内に移動してるキャラクターは衝突判定無視
  end
  #--------------------------------------------------------------------------
  # ● ２点間の x 方向の距離
  #--------------------------------------------------------------------------
  def distance_x(start_x, end_x)
    result = end_x - start_x
    return result unless $game_map.loop_horizontal? && result.abs > $game_map.width / 2
    return result + (result < 0 ? $game_map.width : -$game_map.width)
  end
  #--------------------------------------------------------------------------
  # ● ２点間の y 方向の距離
  #--------------------------------------------------------------------------
  def distance_y(start_y, end_y)
    result = end_y - start_y
    return result unless $game_map.loop_vertical? && result.abs > $game_map.height / 2
    return result + (result < 0 ? $game_map.height : -$game_map.height) 
  end
  #--------------------------------------------------------------------------
  # ● ２点間の z 方向の距離
  #--------------------------------------------------------------------------
  def distance_z(start_z, end_z)
    return end_z - start_z
  end
  #--------------------------------------------------------------------------
  # ● ２点の距離を取得
  #--------------------------------------------------------------------------
  def distance_xy(start_x, start_y, end_x, end_y)
    if @diagonal
      return [distance_x(start_x, end_x).abs, distance_y(start_y, end_y).abs].max # ８方向の場合
    else
      return distance_x(start_x, end_x).abs + distance_y(start_y, end_y).abs      # ４方向の場合
    end
  end
  #--------------------------------------------------------------------------
  # ● x 座標の取得
  #--------------------------------------------------------------------------
  def character_x
    return @character.x
  end
  #--------------------------------------------------------------------------
  # ● y 座標の取得
  #--------------------------------------------------------------------------
  def character_y
    return @character.y
  end
  #--------------------------------------------------------------------------
  # ● z 座標の取得
  #--------------------------------------------------------------------------
  def character_z
    return @character.z
  end
  #--------------------------------------------------------------------------
  # ● z 座標の変換
  #--------------------------------------------------------------------------
  def xyz_to_z(x, y, z)
    return z
  end
  #--------------------------------------------------------------------------
  # ● 進入禁止のリージョンIDの座標か判定
  #--------------------------------------------------------------------------
  def not_enter_coordinate?(x, y, z)
    return not_enter_region_id.include?($game_map.region_id(x, y))
  end
  #--------------------------------------------------------------------------
  # ● 終点か判定
  #--------------------------------------------------------------------------
  def end_coordinate?(x, y, z)
    return x == @gx && y == @gy && z == @gz
  end
  #--------------------------------------------------------------------------
  # ● 終点から範囲内か判定
  #--------------------------------------------------------------------------
  def ending_distance?(x, y, z, distance)
    return false if x == @gx && y == @gy && z != @gz
    return false if distance_xy(x, y, @gx, @gy) > distance
    return true
  end
  # #--------------------------------------------------------------------------
  # # ● 始点から範囲内か判定
  # #--------------------------------------------------------------------------
  # def starting_distance?(x, y, z, distance)
  #   return false if x == @sx && y == @sy && z != @sz
  #   return false if distance_xy(x, y, @sx, @sy) > distance
  #   return true
  # end
  # #--------------------------------------------------------------------------
  # # ● 始点の隣接座標か判定(始点を含む)
  # #--------------------------------------------------------------------------
  # def adjoin_coordinate?(x, y, z)
  #   return false unless starting_distance?(x, y, z, 1)
  #   return xyz_to_z(x, y, @sz) == z
  # end
  #--------------------------------------------------------------------------
  # ● 通行可能判定
  #--------------------------------------------------------------------------
  def passable?(d)
    @character.active_collide_through = @active_collide_through
    @character.collide_through = @collide_through
    @character.search_diagonal = false
    result = base_passable?(:passable?, d)
    @character.collide_through = false
    @character.active_collide_through = false
    return result
  end
  #--------------------------------------------------------------------------
  # ● 斜めの通行可能判定
  #--------------------------------------------------------------------------
  def diagonal_passable?(horz, vert)
    @character.active_collide_through = @active_collide_through
    @character.collide_through = @collide_through
    @character.search_diagonal = true
    result = base_passable?(:diagonal_passable?, horz, vert)
    @character.collide_through = false
    @character.active_collide_through = false
    return result
  end
  #--------------------------------------------------------------------------
  # ● 通行可能判定の呼び出し
  #--------------------------------------------------------------------------
  def base_passable?(name, *d)
    return @character.send(name, @x, @y, *d)
  end
end

#==============================================================================
# ■ 内部処理 ■
#==============================================================================
#==============================================================================
# ■ Route_Search
#------------------------------------------------------------------------------
# 　経路探索の処理を定義したクラスです。
#==============================================================================
class Route_Search
  #--------------------------------------------------------------------------
  # ● 座標の配列のインデックス
  #--------------------------------------------------------------------------
  X = 0                                   # x座標
  Y = 1                                   # y座標
  Z = 2                                   # z座標
  #--------------------------------------------------------------------------
  # ● ノードの配列のインデックス
  #--------------------------------------------------------------------------
  RANK_A = 0                              # 評価値A
  RANK_B = 1                              # 評価値B
  RANK_C = 2                              # 評価値C
  PARENT = 3                              # 親の座標
  LENGTH = 4                              # 移動距離
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :not_enter_region_id      # 進入禁止のリージョンIDの配列
  attr_accessor :limit_search_count       # 探索回数の上限値
  attr_accessor :always_collide_through   # 常に衝突判定を無視のフラグ
  attr_accessor :ending_collide_distance  # 終点付近で衝突判定を無視の距離
  attr_accessor :ending_through_distance  # 終点付近で通行判定を無視の距離
  attr_accessor :diagonal                 # 斜め移動の使用の有無
  attr_accessor :active_collide_through   # 指定フレーム以内に移動してるキャラクターは衝突判定無視
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(character)
    init_base_instance(character)
    @parent = [nil, nil, nil]             # 親の座標
    @past_distance = 0                    # 探索点までの移動距離
    @open_list = {}                       # 探索候補のノードのリスト
    @close_list = {}                      # 探索済みのノードのリスト
    @limit_search_count = 100
    @always_collide_through = false
    @ending_collide_distance = 0
    @ending_through_distance = 0
  end
  #--------------------------------------------------------------------------
  # ● A*経路探索の通常実行
  #--------------------------------------------------------------------------
  def a_star_search(gx, gy, gz=0)
    init_process(gx, gy, gz)              # A*経路探索の初期化
    return main_process                   # A*経路探索の主要処理
  end
  #--------------------------------------------------------------------------
  # ● A*経路探索の初期化
  #--------------------------------------------------------------------------
  def init_process(gx, gy, gz)
    @x, @y, @z = character_x, character_y, character_z # 現在の座標
    @sx, @sy, @sz = @x, @y, @z            # 始点の座標
    @gx, @gy, @gz = gx, gy, gz            # 終点の座標
    @open_list  = {[@sx, @sy, @sz]=>create_node(@sx, @sy, @sz, [nil, nil, nil], 0)}
    @close_list = {}
  end
  #--------------------------------------------------------------------------
  # ● A*経路探索の主要処理
  #--------------------------------------------------------------------------
  def main_process
    count = 0
    until @open_list.empty?
      node, coordinate = get_best_node(@open_list)  # 最も高評価のノードを探索候補のリストから取得
      
      # 探索成功の場合
      return create_route_list(node, coordinate) if end_coordinate?(*coordinate)

      # 探索回数の上限オーバーの場合
      return create_estimate_list if (count += 1) > @limit_search_count

      # 隣接点を探索候補に追加する処理
      @close_list[coordinate] = @open_list.delete(coordinate) # 探索候補から探索済みに移動
      @x, @y, @z     = *coordinate
      @parent        = node[PARENT]
      @past_distance = node[LENGTH] + 1
      down  = $game_map.round_y(@y + 1)
      up    = $game_map.round_y(@y - 1)
      right = $game_map.round_x(@x + 1)
      left  = $game_map.round_x(@x - 1)
      open_list_add(@x, down , 2) # 下
      open_list_add(@x, up   , 8) # 上
      open_list_add(right, @y, 6) # 右
      open_list_add(left , @y, 4) # 左
      if @diagonal
        open_list_add_diagonal(right, down, 6, 2) # 右下
        open_list_add_diagonal(left , down, 4, 2) # 左下
        open_list_add_diagonal(right, up  , 6, 8) # 右上
        open_list_add_diagonal(left , up  , 4, 8) # 左上
      end
    end
    return false  # 到達する経路は存在しない。
  end
  #--------------------------------------------------------------------------
  # ● ノードのデータを生成
  #--------------------------------------------------------------------------
  def create_node(x, y, z, parent, length)
    dx = distance_x(x, @gx).abs
    dy = distance_y(y, @gy).abs
    rank_a = length + dx + dy
    rank_b = Math.sqrt(dx ** 2 + dy ** 2)
    rank_c = distance_z(z, @gz).abs
    return [rank_a, rank_b, rank_c, parent, length]
    # [評価値A, 評価値B, 評価値C, 親の座標, 移動距離]
    # 評価値A : 始点から終点までの推定最短経路の距離
    # 評価値B : 終点との直線距離
    # 評価値C : z 座標の距離
    # 親の座標 : 移動元の座標
    # 移動距離 : 始点からこの点までの移動距離
  end
  #--------------------------------------------------------------------------
  # ● 最も高評価のノードを取得
  #--------------------------------------------------------------------------
  def get_best_node(hash_list, compare=:node_a_better?)
    best_node = [1.0/0, 1.0/0, 1.0/0] # 1.0/0 #=> Infinity
    best_coordinate = nil
    hash_list.each do |coordinate, node|
      next if send(compare, best_node, node)  # node よりも best_node が高評価なら　next
      best_node = node
      best_coordinate = coordinate
    end
    return best_node, best_coordinate
  end
  #--------------------------------------------------------------------------
  # ● ノードの優劣判定
  #--------------------------------------------------------------------------
  def node_a_better?(node_a, node_b)
    return true  if node_a[RANK_A] < node_b[RANK_A]
    return false if node_a[RANK_A] > node_b[RANK_A]
    return true  if node_a[RANK_B] < node_b[RANK_B]
    return false if node_a[RANK_B] > node_b[RANK_B]
    return true  if node_a[RANK_C] < node_b[RANK_C]
    return false if node_a[RANK_C] > node_b[RANK_C]
    return true
  end
  #--------------------------------------------------------------------------
  # ● 探索候補リストに隣接点を追加
  #--------------------------------------------------------------------------
  def open_list_add(nx, ny, d)
    return if @parent[X] == nx && @parent[Y] == ny
    nz = xyz_to_z(nx, ny, @z)                         # z 座標の変換
    result = exception_decision?(nx, ny, nz)
    return if result == false                         # 通行禁止の場合
    if result == nil                                  # 通行可能判定に委ねる場合
      @collide_through = collide_through?(nx, ny, nz)
      return if !passable?(d)                         # 通行可能判定
    end
    open_list_add_node(nx, ny, nz)                    # 探索候補リストに追加
  end
  #--------------------------------------------------------------------------
  # ● 探索候補リストに隣接点を追加(斜めの判定版)
  #--------------------------------------------------------------------------
  def open_list_add_diagonal(nx, ny, horz, vert)
    return if @parent[X] == nx && @parent[Y] == ny
    nz = xyz_to_z(nx, ny, @z)                         # z 座標の変換
    result = exception_decision?(nx, ny, nz)
    return if result == false                         # 通行禁止の場合
    if result == nil                                  # 通行可能判定に委ねる場合
      @collide_through = collide_through?(nx, ny, nz)
      return if !diagonal_passable?(horz, vert)       # 斜めの通行可能判定
    end
    open_list_add_node(nx, ny, nz)                    # 探索候補リストに追加
  end
  #--------------------------------------------------------------------------
  # ● 例外通行判定
  #--------------------------------------------------------------------------
  def exception_decision?(x, y, z)
    return false if not_enter_coordinate?(x, y, z)
    return true if ending_distance?(x, y, z, @ending_through_distance)
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 衝突判定を無視するか判定
  #--------------------------------------------------------------------------
  def collide_through?(x, y, z)
    return true if @always_collide_through
    return true if ending_distance?(x, y, z, @ending_collide_distance)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 探索候補リストに隣接点を追加する処理
  #--------------------------------------------------------------------------
  def open_list_add_node(nx, ny, nz)
    next_coordinate = [nx, ny, nz]
    if old_node = @close_list[next_coordinate]                            # 探索済みリストに既にある場合
      if old_node[LENGTH] > @past_distance                                # 移動距離が優れている場合
        @open_list[next_coordinate] = @close_list.delete(next_coordinate) # 探索候補リストに移動
        update_node(old_node)
      end
      return
    end
    if old_node = @open_list[next_coordinate]                             # 探索候補リストに既にある場合
      update_node(old_node) if old_node[LENGTH] > @past_distance          # 移動距離が優れている場合
      return
    end
    @open_list[next_coordinate] = create_node(*next_coordinate, [@x, @y, @z], @past_distance)
  end
  #--------------------------------------------------------------------------
  # ● ノードのデータを更新
  #--------------------------------------------------------------------------
  def update_node(old_node)
    old_node[RANK_A] += @past_distance - old_node[LENGTH] # 移動距離の差を減算
    old_node[PARENT]  = [@x, @y, @z]                      # 親の座標を更新
    old_node[LENGTH]  = @past_distance                    # 移動距離を更新
  end
  #--------------------------------------------------------------------------
  # ● 経路の配列を生成
  #--------------------------------------------------------------------------
  def create_route_list(node, coordinate)
    parent = node[PARENT]
    route_list = []
    while parent != [nil, nil, nil]
      route_list.push coordinate
      parent = @close_list[coordinate = parent][PARENT]
    end
    return route_list # 先頭が終点で末尾が始点の次の座標(推定経路の場合は先頭は終点ではない)
  end
  #--------------------------------------------------------------------------
  # ● 推定経路の配列を生成
  #--------------------------------------------------------------------------
  def create_estimate_list
    open_node, open_coordinate = get_best_node(@open_list, :estimate_node_a_better?)
    close_node, close_coordinate = get_best_node(@close_list, :estimate_node_a_better?)
    if estimate_node_a_better?(open_node, close_node)
      return create_route_list(open_node, open_coordinate)
    else
      return create_route_list(close_node, close_coordinate)
    end
  end
  #--------------------------------------------------------------------------
  # ● ノードの優劣判定(推定経路用)
  #--------------------------------------------------------------------------
  def estimate_node_a_better?(node_a, node_b)
    return true  if node_a[RANK_B] < node_b[RANK_B]
    return false if node_a[RANK_B] > node_b[RANK_B]
    return true  if node_a[RANK_C] < node_b[RANK_C]
    return false if node_a[RANK_C] > node_b[RANK_C]
    return true
  end
  #--------------------------------------------------------------------------
  # ● 探索結果を再利用
  #--------------------------------------------------------------------------
  def reuse_route_list(route_list, reuse_distance, gx, gy, gz=0)
    return false unless route_list
    @sx, @sy, @sz = character_x, character_y, character_z
    return false unless index = route_list.index([@sx, @sy, @sz]) # 始点を含んでいるか判定
    (route_list.size - index).times { route_list.pop }
    return false if route_list.empty?
    @gx, @gy, @gz = gx, gy, gz
    if index = route_list.index([@gx, @gy, @gz])                  # 終点を含んでいるか判定
      index.times { route_list.shift }
      return false unless route_list_valid?(route_list)           # 経路を使用可能か判定
      return route_list
    else
      return false unless ending_distance?(*route_list[0], reuse_distance)
      return false unless route_list_valid?(route_list)           # 経路を使用可能か判定
      reuse_search(route_list)                                    # 以前の探索結果を使用して経路探索
    end
  end
  #--------------------------------------------------------------------------
  # ● 経路を使用可能か判定
  #--------------------------------------------------------------------------
  def route_list_valid?(route_list)
    @x, @y, @z = @sx, @sy, @sz
    route_list.reverse.each do |coordinate|
      nx, ny, nz = *coordinate
      result = exception_decision?(nx, ny, nz)
      return false if result == false                             # 通行禁止の場合
      if result == nil                                            # 通行可能判定に委ねる場合
        @collide_through = collide_through?(nx, ny, nz)
        if nx == @x
          return false unless ny == @y ? nil          : (ny > @y ? passable?(2)             : passable?(8)            )
        elsif nx > @x
          return false unless ny == @y ? passable?(6) : (ny > @y ? diagonal_passable?(6, 2) : diagonal_passable?(6, 8))
        else
          return false unless ny == @y ? passable?(4) : (ny > @y ? diagonal_passable?(4, 2) : diagonal_passable?(4, 8))
        end
      end
      @x , @y , @z  = nx, ny, nz
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 以前の探索結果を使用して経路探索
  #--------------------------------------------------------------------------
  def reuse_search(route_list)
    init_process(@gx, @gy, @gz)
    parent = [@sx, @sy, @sz]
    route_list.reverse.each do |coordinate|
      @open_list[coordinate] = create_node(*coordinate, parent, 0)  # 移動距離に細工をして追加
      parent = coordinate
    end
    @close_list = @open_list.dup
    return main_process
  end
end

#==============================================================================
# ■ マルチレイヤーシステムとの競合回避 ■
#==============================================================================
if $imported[:CanariAlternate_Multilayer]
  #==============================================================================
  # ■ Game_CharacterBase
  #------------------------------------------------------------------------------
  # 　キャラクターを扱う基本のクラスです。全てのキャラクターに共通する、座標やグ
  # ラフィックなどの基本的な情報を保持します。
  #==============================================================================
  class Game_CharacterBase
    #--------------------------------------------------------------------------
    # ● z 座標の取得 [◆再定義]
    #--------------------------------------------------------------------------
    def z
      return current_floor
    end
  end
  #==============================================================================
  # ■ Route_Search
  #------------------------------------------------------------------------------
  # 　経路探索の処理を定義したクラスです。
  #==============================================================================
  class Route_Search
    #--------------------------------------------------------------------------
    # ● 定数
    #--------------------------------------------------------------------------
    DummyEvent = Game_CharacterBase.new     # ダミーのイベント
    #--------------------------------------------------------------------------
    # ● z 座標の変換 [◆再定義]
    #--------------------------------------------------------------------------
    def xyz_to_z(x, y, z)
      return $game_map.floor_xy(x, y, z)
    end
    #--------------------------------------------------------------------------
    # ● 進入禁止のリージョンIDの座標か判定 [◆再定義]
    #--------------------------------------------------------------------------
    def not_enter_coordinate?(x, y, z)
      return not_enter_region_id.include?($game_map.region_id(x, y, z))
    end
    #--------------------------------------------------------------------------
    # ● 通行可能判定の呼び出し [◆再定義]
    #--------------------------------------------------------------------------
    def base_passable?(name, *d)
      DummyEvent.current_floor = @z
      return $game_map.temp_execute(DummyEvent) { @character.send(name, @x, @y, *d) }
    end
  end
end