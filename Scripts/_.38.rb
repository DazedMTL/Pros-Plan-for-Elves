=begin
      RGSS3
      
      ★ ロードメニュー ★
      
      メニューにセーブデータのロードを行える項目を追加します。
      
      ● 仕様 ●==========================================================
      セーブが一つも存在しない場合は、コマンドを選択することはできません。
      ====================================================================
      
      ver1.00

      Last Update : 2011/12/25
      12/25 : 新規
      
      ろかん　　　http://kaisou-ryouiki.sakura.ne.jp/
=end

$rsi ||= {}
$rsi["ロードメニュー"] = true

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  alias _make_command_list_with_load_command make_command_list
  def make_command_list
    _make_command_list_with_load_command
    add_load_command
  end
  #--------------------------------------------------------------------------
  # ● インデックスを指定したコマンドの追加
  #--------------------------------------------------------------------------
  def add_command_with_index(name, symbol, index, enabled = true, ext = nil)
    @list[index, 0] = {:name=>name, :symbol=>symbol, :enabled=>enabled, :ext=>ext}
  end
  #--------------------------------------------------------------------------
  # ● ロードコマンドの追加
  #--------------------------------------------------------------------------
  def add_load_command
    @list.each_with_index{|data, index|
      if data[:symbol] == :save
        add_command_with_index("Load", :load, index.next, DataManager.save_file_exists?)
        return
      end
    }
    add_command("Load", :load, DataManager.save_file_exists?)
  end
end

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias _create_load_command create_command_window
  def create_command_window
    _create_load_command
    @command_window.set_handler(:load, method(:command_load))
  end
  #--------------------------------------------------------------------------
  # ● コマンド［ロード］
  #--------------------------------------------------------------------------
  def command_load
    SceneManager.call(Scene_Load)
  end
end