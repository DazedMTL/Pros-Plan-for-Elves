#===============================================================================
# 2018/07/04 kido0617
# http://kido0617.github.io/
# 完全に自由にどうぞ。
# クレジットの表記もいりません。
# 詳細: http://kido0617.github.io/rpgmaker/2018-07-05-debug-shortcut-vxace
# Ver.1.0
#-------------------------------------------------------------------------------

class Scene_Debug < Scene_MenuBase

  KEYS = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 83, 86, 8]
  DOWN_STATE_MASK   = (0x8 << 0x04)
  @@GetKeyState = Win32API.new('user32','GetKeyState',['L'],'L')

  alias my_debug_start start
  def start
    my_debug_start
    @keyPressed = {}
    KEYS.each do |key|
      @keyPressed[key] = false
    end
    @short_cut = ''
    @str_num = ''
  end

  def update
    super
    KEYS.each do |key|
        on = @@GetKeyState.call(key) & DOWN_STATE_MASK == DOWN_STATE_MASK
        if !@keyPressed[key] && on
          trigger(key)
        end 
        @keyPressed[key] = on
    end
  end

  def trigger(key)
    if key == 83 #S
      @short_cut = 'S'
      @str_num = ''
      jump()
    elsif key == 86 #V
      @short_cut = 'V'
      @str_num = ''
      jump()
    elsif key == 8 #backspace
      return if @str_num.length == 0
      @str_num = @str_num.slice(0, @str_num.length - 1)
      jump()
    else
      return if @str_num.length == 0 && key == 48 #いきなり0はだめ
      @str_num += (key - 48).to_s
      jump()
    end
  end

  def jump()
    return if @short_cut == nil
    switchMax = ($data_system.switches.size - 1 + 9) / 10
    rangeIndex = @short_cut == 'S' ? 0 : switchMax;
    if @str_num != ''
      num = @str_num.to_i;
      if (@short_cut =='S' && num > $data_system.switches.size - 1) || (@short_cut =='V' && num > $data_system.variables.size - 1)
         Sound.play_buzzer
         num = @short_cut == 'S' ?  $data_system.switches.size - 1 : $data_system.variables.size - 1
      end
      rangeIndex += ((num - 1) / 10).floor;
      @left_window.select(rangeIndex);
      @left_window.deactivate();
      @right_window.activate();
      @right_window.select((num -1) % 10);
    else
      @left_window.select(rangeIndex);
      @left_window.activate();
      @right_window.deactivate();
    end
    refresh_help_window()
  end

  alias my_refresh_help_window refresh_help_window
  def refresh_help_window
    @debug_help_window.contents.clear
    my_refresh_help_window
    str = @short_cut + @str_num;
    @debug_help_window.draw_text_ex(270, @debug_help_window.line_height() * 4, str)
  end
end