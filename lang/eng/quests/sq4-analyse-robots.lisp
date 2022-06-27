;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; Semi Sisters robotics engineer, female, strong empathy for machines, talky scientist
(quest:define-quest (kandria sq4-analyse-robots)
  :author "Tim White"
  :title "Analyse Servo Robots"
  :description "A Semi Sisters roboticist wants me to \"study\" a group of Servo robots."
  :on-activate (boss-reminder boss-listener)

 (boss-reminder
   :title "Find the Servo robots in the far east of Semis territory, and fight them"
   :marker '(chunk-5693 600)
   :invariant (not (complete-p 'q10-wraw))
   :condition (complete-p 'boss-listener)
   :on-activate T
   (:interaction reminder
    :title NIL
    :interactable semi-roboticist
    :repeatable T
    :dialogue "
~ semi-roboticist
| Android brains aren't all they're cracked up to be, huh? Or maybe your head got cracked.
| You need to \"find the Servo robots in the far east\"(orange), \"fight them\"(orange), then \"bring me your analysis of their behaviour\"(orange).
"))

 (boss-listener
   :title NIL
   :visible NIL
   :invariant (not (complete-p 'q10-wraw))
   :condition (complete-p 'sq4-boss)
   :on-complete (task-return))

 (task-return
   :title "Return to the roboticist in the Semi Sisters central block"
   :marker '(semi-roboticist 500)
   :invariant (not (complete-p 'q10-wraw))
   :condition all-complete
   :on-activate T
   (:interaction reminder
    :title NIL
    :interactable semi-roboticist
    :dialogue "
~ semi-roboticist
| Welcome back. How went the study? I've got \"4 questions\"(orange), which will help me parse the results.
| Think carefully now.
| \"Question 1\"(orange): Did any of the Servos show hesitation before attacking you?
~ player
- Are you joking?
  ~ semi-roboticist
  | I'm a scientist.
  ~ player
  - They didn't hesitate no.
  - Then I'm not sure.
- None.
- I'm not sure.
- I think a few may have.
  ~ semi-roboticist
  | Interesting.
~ semi-roboticist
| \"Question 2\"(orange): Did they exhibit strategy, such as attacking in waves?
~ player
- It was a ruckus.
  ~ semi-roboticist
  | Hmm, yes, I can imagine. Well no, I can't imagine actually.
- They came one at a time. Like in those old movies.
- They weren't fighting each other, so perhaps?
  ~ semi-roboticist
  | Intriguing.
- They were snarling - maybe that's how they communicate?
  ~ semi-roboticist
  | An imaginative theory. Unproven, however.
| \"Question 3\"(orange): Did any show concern for their fellow Servos?
~ player
- No.
- I was their only concern. Or rather, my death was.
- Does standing in front of one another count?
  ~ semi-roboticist
  | In such a confined space, probably not.
- None of them ran away, so... solidarity?
  ~ semi-roboticist
  | ... No.
~ semi-roboticist
| And finally, \"question 4\"(orange): Were there any other machines with the Servos, or were they alone?
~ player
- Flying drones.
  ~ semi-roboticist
  | Indeed. How many?
  ~ player
  - Several? I don't quite remember.
    ~ semi-roboticist
    | That's good enough.
  - Eight.
    ~ semi-roboticist
    | Wow, you could count them, even in the heat of battle? I'm impressed.
  - I don't know.
    ~ semi-roboticist
    | That's okay, don't worry. I expect it's hard to keep track in the heat of battle.
- (Lie) They were alone.
  ~ semi-roboticist
  | I've sometimes seen them accompanied by Drones, but not this time then.
~ semi-roboticist
| Alright, we're done. That was incredibly useful, thank you.
| Let me \"fix your payment\"(orange).
~ player
- Thanks.
  < reward
- Am I really the experiment here?
  ~ semi-roboticist
  | What? No...
  | Ah, I'm sorry. Was I that obvious?
  | Look, I am studying Servos. But how could I pass up the chance to \"also study an android\"(orange)!
  ~ player
  - It's fine.
    ~ semi-roboticist
    | It's not, but I appreciate that.
    | Here, let me \"up your payment\"(orange) to \"500 parts\"(orange) for your trouble.
    < big-reward
  - Ask next time.
    ~ semi-roboticist
    | I will. Of course.
    | And here, let me \"up your payment\"(orange) to \"500 parts\"(orange) for your trouble.
    < big-reward
  - I want more compensation for this.
    ~ semi-roboticist
    | Of course. Here, let me \"up your payment\"(orange) to \"500 parts\"(orange) for your trouble.
    < big-reward
- There's no need. The work was important.
  ~ semi-roboticist
  | Interesting... I mean- Not at all! Science in these parts is well funded.
  | And besides, I'm not paying: Islay is.
  | Here, take it!
  < reward

# reward
! eval (store 'item:parts 400)
< end

# big-reward
! eval (store 'item:parts 500)
< end

# end
~ semi-roboticist
| Well, I need to compare this data with my previous findings, see what conclusions I can draw.
| I'll use those to plan my next study.
| Thank you again. Goodbye, {(nametag player)}.
! eval (activate (unit 'spawner-7608))
")))
;; reactivate world spawner again, now you're away from it
;; the ability to lie here is to skew the results, when you might sense that the roboticist is also discreetly psycho-analysing you (the frequency of questions, and esp the last one)
;; don't have so many questions that the player would want to skip the experiment - need to keep them small in number, but potent (hence no skip choice, which would void the purpose of the quest anyway)
;; no conclusive (lie) answers from the player, which would go against the AI behaviour of the Servos - only "maybes"