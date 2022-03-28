;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q5-run-errands)
  :author "Tim White"
  :title ""
  :visible NIL
  (:eval 
   (setf (location 'innis) (location 'innis-main-loc))
   (setf (direction 'innis) 1)
   (setf (location 'islay) (location 'islay-errand-spawn))
   (move-to 'alex (unit 'islay)))
   (:go-to (islay :follow islay))
  (:interact (islay :now T)
   "
~ islay
| Hello again. You found Alex, I see. How are they?
~ player
- Drunk as a skunk.
- They won't cooperate.
- See for yourself.
~ islay
| (:nervous)I feared as much.
| (:normal)What if I talk to them?
~ player
- I'd appreciate that.
  ~ islay
  | (:happy)It's the least I can do.
- What's the catch?
  ~ islay
  | No catch. I just want to help.
- I think they're a lost cause.
  ~ islay
  | Maybe. But were you yourself not a lost cause before Alex found you?
~ islay
| You should stay with us a while, give me some time.
| (:expectant)That way you won't disappoint Fi by returning empty-handed.
| And there are things you could help us with.
~ player
- So there is a catch.
  ~ islay
  | No. This isn't a trade. You're free to go and do anything you want.
  | (:expectant)But it couldn't hurt to show my sister what you can do, could it? Sow some seeds of diplomacy.
- Like turning me into a battery?
  ~ islay
  | Of course not. You're free to go and do anything you want.
  | (:expectant)But it couldn't hurt to show my sister what you can do, could it? Sow some seeds of diplomacy.
- What things?
  ~ islay
  | (:expectant)Well, it couldn't hurt to show my sister what you can do, could it? Sow some seeds of diplomacy.
- [(var 'android-soft) Won't Innis think you've gone soft for androids?]
  ~ islay
  | (:nervous)... Touché.
  | (:normal)I'll deal with that. But it couldn't hurt to show her what you can do, could it? Sow some seeds of diplomacy.
~ player
- You're right.
  ~ islay
  | Aye, sometimes I'm right.
- Tell that to your sister.
  ~ islay
  | I do. Frequently. Innis has her qualities. Diplomacy isn't one of them.
- Diplomacy does not compute.
  ~ islay
  | Come now, you're no mere servo. I know you understand.
~ islay
| (:happy)I can sweeten the deal too.
| (:normal)I suppose I'm what you'd call the chief engineer around here. Just like Jack is for the Noka.
| Which means I stock many things that might be useful to you.
| We get the usual traders visiting of course, but I'm giving you another option - and \"I stock more supplies than most\"(orange).
| (:expectant)Anyhow, much as I'd hate to send you back into the jaws of my sister, she's got my report on our most urgent needs.
| We've got \"rail engineers stuck\"(orange) after a tunnel collapse in the \"high west\"(orange).
| And \"4 of our CCTV cameras on the low eastern\"(orange) Cerebat border have gone down.
| (:normal)So leave Alex to me, and if you'd like to help, \"speak with Innis - she's gone up to the control room\"(orange).
| Perhaps see her as another challenge to overcome. (:happy)I know I do.
| (:normal)Ta-ta for now, Stranger.
! eval (stop-following 'islay)
! eval (move-to 'islay-alex-talk (unit 'islay))
! eval (activate 'trader-semi-chat)
! eval (activate 'trader-shop-semi)
! eval (activate 'q5-intro)
"))
;;TODO different prices for different traders, so write in that Islay gives you a good discount?
