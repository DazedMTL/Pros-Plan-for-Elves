#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
#
#キャラ説明を変更します
#
#
#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

module DescriptionChange
  CHANGE = [
  #★設定項目
  #配列１個目
  [
  1, # キャラ説明を変更するキャラ
  143, # キャラ説明変更に使うスイッチ
  
  #↓で制御文字を使う場合、例のように\を２つ付けます。
  #変更後のキャラ説明１行目
  "このように\\C[2]キャラ説明を変える事が出来ます\\c[0]。\\n[1]",
  #変更後のキャラ説明２行目
  "あまり長くし過ぎると、説明が途切れてしまうので注意して下さい。"
  ],
  #配列２個目（もっと変更したい場合、配列をコピペしてご使用下さい）
  [
  1,
  146,
  "The princess of the Elven Empire who has truly become a prostitute.",
  "Naturally, her true identity is only known to a select few"
  ],
  #配列３個目
  [
  1,
  147,
  "The princess was purchased in a virgin auction and creampied by a human man.",
  "With this, she finally takes a step towards becoming a professional prostitute."
  ],
  #配列４個目
  [
  1,
  148,
  "Having gained experience, she has become a somewhat well-known prostitute in the industry.",
  "Her resistance to having sex with humans is gradually diminishing." 
  ],
  #配列５個目
  [
  1,
  152,
  "By being embraced by many men, she has grown into a true prostitute.",
  "Taking advantage of the difficulty of getting pregnant, she has come to enjoy creampie sex." 
  ],
  #配列６個目
  [
  1,
  153,
  "During the process of anal training, Sylphy realized her craving for pregnancy.",
  "She is gradually becoming a depraved female pig who delights in being defiled." 
  ],
  #配列７個目
  [
  1,
  154,
  "She has finally become pregnant with a human child.",
  "Confused by her swollen belly, she considers her own appearance to be ugly."
  ],
  #配列８個目
  [
  1,
  155,
  "She has been trained and disciplined as a depraved female pig by the men of the Twin Towers.",
  "She has grown into a more insatiable whore, craving men even more than before."
  ],
  #配列１０個目
  [
  1,
  157,
  "She now proudly exposes her pregnant belly and actively seeks clients.",
  "She has gained a reputation as a perverted prostitute who will mate with anyone."
  ],
  #配列１１個目
  [
  1,
  158,
  "She has already reached a level of expertise as a prostitute.",
  "However, she is still fundamentally weak to cocks and often gets manipulated by her clients."
  ],
   #配列１２個目
  [
  1,
  159,
  "She entered into a mistress relationship with Gamasu, a dairy farmer she had known since coming to the town.",
  "It seems like he has something different in mind, and Sylphy is also looking forward to it."
  ],
   #配列１２個目
  [
  1,
  160,
  "She experienced the pleasure of a threesome in the boys' secret base.",
  "In essence, she has become their woman, treated as such by them."
  ],
    #配列１３個目
  [
  1,
  166,
  "She has finally regained her freedom.",
  "However, the fact that she has become a female pig does not disappear."
  ],
  #★設定項目終わり
  ]
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 説明の取得
  #--------------------------------------------------------------------------
  alias description_change description
  def description
    DescriptionChange::CHANGE.each do |des|
      return des[2] + "\n" + des[3] if actor.id == des[0] && $game_switches[des[1]]
    end
    description_change
  end
end