;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-catherine)
  :author "Tim White"
  :title "Bring Catherine to Engineering"
  :description "Islay needs to talk to Catherine about checking why the bombs didn't explode."
  (:go-to (catherine)
   :title "Talk to Catherine outside Engineering")
  (:interact (catherine)
   :title "Talk to Catherine outside Engineering"
    "
~ catherine
| Hey, {#@player-nametag}.
~ player
- Islay needs to talk to you urgently.
  ~ catherine
  | (:concerned)Oh, okay.
- You ready for another adventure?
  ~ catherine
  | (:excited)With you? Always!
- Looks like the old team is getting back together.
  ~ catherine
  | What, you and I?
  | (:excited)What's the plan?
~ player
| \"I lower my vocal volume so only Catherine can hear.\"(light-gray, italic)
| (:embarassed)The bombs didn't detonate.
~ catherine
| (:shout)<-WHAT?!->
~ player
| Come with me to \"Engineering\"(orange).
")
  (:eval
   (ensure-nearby 'bomb-1 'islay)
   (setf (walk 'catherine) NIL))
  (:go-to (eng-cath :with catherine)
   :title "Return with Catherine and talk to Islay in Engineering")
  (:interact (fi :now T)
    "
~ fi
| (:annoyed)Islay's gone. I couldn't stop her.
| She said the only way to be sure was if she checked the bombs herself.
~ player
- What?!
- She's too old.
  ~ fi
  | She might surprise you.
- Then she's dead.
  ~ fi
  | She might surprise you.
~ catherine
| (:concerned)Islay...
~ fi
| She did design the bombs, so if anyone can fix them it's her.
~ player
- We should go after her.
  ~ fi
  | I'm afraid I agree. She'll have better luck solving it with your help, Catherine.
  | Even though she said not to follow.
- Did she say anything else?
  ~ fi
  | She said not to follow.
  | But I think she'll have better luck solving it with your help, Catherine.
  | I'm afraid you both need to go after her.
- What now?
  ~ fi
  | I'm afraid you both need to go after her - even though she said not to follow.
  | She'll have better luck solving it with your help, Catherine.
~ catherine
| (:shout)Then let's go!
~ fi
| Is your FFCS working?
~ player
| \"Checking FFCS...\"(light-gray, italic)
| (:skeptical)No. Wraw interference.
~ fi
| Then take this walkie. Try calling her once you're down there, find out where she is.
! eval (store 'item:walkie-talkie-2 1)
! eval (follow 'player 'catherine)
")
  (:eval
   :on-complete (q15-unexploded-bomb)
   (activate (unit 'islay-bomb-1))
   (activate (unit 'islay-bomb-2))
   (activate (unit 'islay-bomb-3))
   (activate (unit 'islay-bomb-4))))