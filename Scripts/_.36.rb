#==============================================================================
# RGSS3_使用者名の後にアイコン表示 ver1.01
# 2014/06/18公開
# 2014/06/25スクリプト整理
# C Winter (http://ccwinter.blog.fc2.com/)
#==============================================================================

=begin

「画面上部にスキル名表示1.08」拡張

(アイコン　使用者名　表示内容)の順番で表示していたのを
(使用者名　アイコン　表示内容)の順番にする


「画面上部にスキル名表示」本体の設定項目 USERNAME_ADD は使わない

=end


#==============================================================================
# ■ 設定項目
#==============================================================================
module Top_Skill::Icon_UserName
  
  # 表示するのが「使用者名　アイコン　表示内容」か「アイコン　表示内容」の時
  #  [使用者名とアイコンの間の空白, アイコンと表示内容の間の空白]  の幅
  SPACE_A = [12, 0]
  
  # 表示するのが「使用者名　表示内容」の時
  #   使用者名と表示内容の間の空白  の幅
  SPACE_B = 24
  
end


#==============================================================================
# ■ Window_TopSkillName
#==============================================================================
class Window_TopSkillName < Window_Help
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    name_flag = !@user_name.empty?
    icon_flag = @icon ? true : false
    
    rect_name = text_size(@user_name)
    rect_text = text_size(@text)
    
    w_name = rect_name.width
    w_icon = 24
    w_text = rect_text.width
    
    s_a = Top_Skill::Icon_UserName::SPACE_A
    s_b = Top_Skill::Icon_UserName::SPACE_B
    
    case [name_flag, icon_flag]
    when [ true,  true]
      all_width = w_name + s_a[0] + w_icon + s_a[1] + w_text
      x_name = 0
      x_icon = w_name + s_a[0]
      x_text = w_name + s_a[0] + w_icon + s_a[1]
    when [ true, false]
      all_width = w_name + s_b + w_text
      x_name = 0
      x_text = w_name + s_b
    when [false,  true]
      all_width = w_icon + s_a[1] + w_text
      x_icon = 0
      x_text = w_icon + s_a[1]
    when [false, false]
      all_width = w_text
      x_text = 0
    end
    
    base_x = (contents_width - all_width) / 2
    draw_text_ex(base_x + x_name, 0, @user_name) if name_flag
    draw_icon(@icon, base_x + x_icon, 0) if icon_flag
    draw_text_ex(base_x + x_text, 0, @text)
  end
end