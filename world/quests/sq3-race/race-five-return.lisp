(:name race-five-return
 :title "Return the can to Catherine ASAP"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (activate-chat)
 :on-complete NIL)

(quest:action :name activate-chat :on-activate (progn
                                                 (setf (quest:status (thing 'race-five-chat)) :inactive)
                                		 (activate 'race-five-chat)))

(quest:interaction :name race-five-chat :title "Complete Route 5" :interactable catherine :dialogue "
! eval (hide-panel 'timer)
~ catherine
| Stop the clock!
| That's the can for Route 2 alright - nice!
! eval (retrieve 'can)
| You did that in: {(format-relative-time (clock quest))}!
  
? (< (clock quest) 120)
| | How did you do that so fast? That's gold bracket.
| | You get the top reward - 50 scrap parts!
| ! eval (store 'parts 50)
| ? (not (var 'race-5-gold))
| | | I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-5-gold) (clock quest))
| |? (< (clock quest) (var 'race-5-gold))
| | | And you beat your best gold time, way to go!
| |? (= (clock quest) (var 'race-5-gold))
| | | You equalled your best gold time as well, what are the chances?!
| |?
| | | You didn't beat your best gold time, but it's still good!
|? (< (clock quest) 180)
| | That's pretty quick! Silver bracket.
| | That nets you 30 scrap parts!
| ! eval (store 'parts 30)
| ? (not (var 'race-5-silver))
| | | I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-5-silver) (clock quest))
| |? (< (clock quest) (var 'race-5-silver))
| | | And you beat your best silver time, way to go!
| |? (= (clock quest) (var 'race-5-silver))
| | | You equalled your best silver time as well, what are the chances?!
| |?
| | | You didn't beat your best silver time, but it's still good!
|? (< (clock quest) 240)
| | Not bad. That's bronze bracket.
| | That gets you 20 scrap parts.
| ! eval (store 'parts 20)
| ? (not (var 'race-5-bronze))
| | | I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-5-bronze) (clock quest))
| |? (< (clock quest) (var 'race-5-bronze))
| | | And you beat your bronze time, way to go!
| |? (= (clock quest) (var 'race-5-bronze))
| | | You equalled your best bronze time as well, what are the chances?!
| |?
| | | You didn't beat your best bronze time, but it's still good!
|?
| | Hmmm, that's a little slow, Stranger. I think you can do better than that.
| | Don't think I can give you any parts for that, sorry.
? (not (var 'race-5-pb))
| | I've also logged your time as your personal best for this route.
| ! eval (setf (var 'race-5-pb) (clock quest))
|? (< (clock quest) (var 'race-5-pb))
| | You beat your personal best too! I'm so proud of you.
| ! eval (setf (var 'race-5-pb) (clock quest))
|? (= (clock quest) (var 'race-5-pb))
| | You equalled your personal best too - that's amazing!
|?
| | Alas you didn't beat your personal best. But there's always next time!
! eval (complete 'race-five-return)
  
| Let's do this again soon!
")
