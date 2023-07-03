#===================================
# 「大事なもの」の個数を描画しない
#===================================

class Window_ItemList < Window_Selectable
#--------------------------------------------------------------------------
# ● アイテムの個数を描画
#--------------------------------------------------------------------------
def draw_item_number(rect, item)
if @category != :key_item
draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
end
end
end