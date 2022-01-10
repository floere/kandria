;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-semi-chat)
  :author "Tim White"
  :title "Trade With Islay"
  :description NIL
  :visible NIL
  :variables (alex-done)
  :on-activate T
  (chat-semi
   :title NIL
   :on-activate T
   (:interaction chat-semi
    :title "Can I talk to you?"
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
| Of course.
! label talk
? (not (complete-p 'q7-my-name))
| ~ player
| - [(not (var 'alex-done)) How's Alex?|]
|   ? (and (complete-p 'q5a-rescue-engineers) (complete-p 'q5b-investigate-cctv))
|   | ~ alex
|   | | (:angry)What's the matter? Afraid to talk to me yourself, android? <-Hic->.
|   | ~ islay
|   | | (:nervous)The barkeep has stopped serving them, which is something.
|   | ~ alex
|   | | (:angry)Oi, android. <-Hic->. I 'ear you even stole my jobs around 'ere now too.
|   | | Fucker.
|   | ~ islay
|   | | (:expectant)You could work together Alex, for the Noka. Return to Fi together with Stranger, and get your old life back.
|   | ~ alex
|   | | (:unhappy)\"Stranger\", ha. Don't make me laugh- <-Hic->. I'm the stranger. Stranger to my own people. Stranger to myself.
|   | | I'm going nowhere. Get lost, both of you.
|   | ~ islay
|   | | (:normal)Perhaps it would be best if we leave them alone for a while.
|   | | I suggest you deliver your findings to Fi.
|   | | We'll speak again.
|   | ! eval (setf (var 'alex-done) T)
|   | ! eval (setf (walk 'islay) T)
|   | ! eval (move-to 'islay-main-loc (unit 'islay))
|   |?
|   | ~ islay
|   | | (:unhappy)Not much better I'm afraid. They're an alcoholic.
|   | | (:normal)I think talking is helping though.
|   | | If I can get them out of this bar it'll be a start.
|   | < talk
| - Why spy on the Noka?
|   ~ islay
|   | (:nervous)We spy on everyone. It's just what we do, it's nothing personal.
|   | (:normal)We have the technology, and the motivation. I don't know if you noticed, but most people down here are trying to kill each other.
|   | For what it's worth I value our friendship with the Noka. Innis does too, in her own way.
|   < talk
| - Can you read my black box?
|   ~ islay
|   | You're curious if you betrayed the Noka.
|   | We know a lot about you - but no, we can't read your black box. No one can any more. I'm sorry.
|   | (:nervous)I saw what happened with the servo robots - whether they acted independently, or were being controlled, it's hard to say.
|   < talk
| - What do you remember from before the Calamity?
|   ~ islay
|   | (:unhappy)It was another world, another lifetime.
|   | (:normal)If you're wondering whether androids destroyed the world, I can't help you.
|   | I wasn't on the surface - (:unhappy)few of us were, that's why we're still here.
|   | (:normal)But I don't see how that would've been possible.
|   | And even if androids did, I doubt very much it was their own doing. No.
|   | No one destroyed humanity except humanity.
|   < talk
| - That'll do.
|   < leave
|? (and (complete-p 'q7-my-name) (not (complete-p 'q10-wraw)))
| ~ player
| - What's happening on the Cerebat border?
|   ~ islay
|   | (:nervous)We're still trying to ascertain that - but we've lost more cameras since you left.
|   | (:normal)Innis thinks we're next, but I'm not so sure.
|   | The Wraw are primitive. Maybe they are messing with the Cerebats, but they wouldn't stand a chance against our technology.
|   | (:expectant)And I'm not just talking about surveillance. We have weapons.
|   ! eval (setf (var 'semis-weapons) T)
|   < talk
| - How's Alex now?
|   ~ islay
|   | (:nervous)They've gone. I don't know where. They just upped and left.
|   | If they've not returned to the Noka then God knows.
|   | I hope they're okay. And sober.
| - Why are the Semis mostly women?
|   ~ islay
|   | (:unhappy)Why not?
|   | (:normal)... Most of us who worked in the factories were women. After the Calamity we just stayed together.
|   | And we've done better than most.
|   | (:happy)Maybe the world wouldn't have fallen apart if more women were in charge.
|   ~ player
|   - Touché.
|     < talk
|   - You're so right.
|     < talk
|   - What about having kids?
|     ~ islay
|     | We have more than enough men.
|     | Besides, technology can help us with that too.
|     | But not everyone wants kids. I never did.
|     | Some say we should repopulate as quickly as possible. Those with a brain say the world can't support a large population any more.
|     < talk
|   - Let's talk about something else.
|   < talk
| - I need to go.
|   < leave
|? (and (complete-p 'q10-wraw) (not (active-p 'q11-recruit-semis)))
| ~ player
| | The Wraw are coming.
| ~ islay
| | (:nervous)Thank you, but we know. We're making preparations.
| ~ player
| - Of course you do.
|   ~ islay
|   | (:happy)...
|   | Good luck, {#@player-nametag}.
| - What preparations?
|   ~ islay
|   | (:nervous)I'm afraid I can't share that. I'm sorry.
|   | Good luck, {#@player-nametag}.
| - Good luck.
|   ~ islay
|   | Thank you, {#@player-nametag}. To you too.
|? (active-p 'q11-recruit-semis)
| ~ player
| - How will the Noka and Semis work together?
|   ~ innis
|   | Living space will be tight, but only for short time, before we can move back home (bomb not intended to destroy area permanently)
| - Tell me more about the bomb.
|   ~ player
|   | Get in joke about: Blasting caps - are they a kind of mushroom? ;)
| - Are you in charge now?
|   ~ innis
|   | God no. Innis is the leader around here - which is the way we both like it.
|   | I prefer to stand back. But I have her ear, and she listens to me.
| - I need to go.
|   < leave

# leave
~ islay
| [? Take care, {#@player-nametag}. | Mind how you go. | I'll be seeing you. | Ta-ta.]")))

(quest:define-quest (kandria trader-shop-semi)
  :title "Trade"
  :visible NIL
  :on-activate T
  (trade-shop-semi
   :title "Trade"
   :on-activate T
   (:interaction buy
    :interactable islay
    :repeatable T
    :title (@ shop-buy-items)
    :dialogue "! eval (show-sales-menu :buy 'islay)")
   (:interaction sell
    :interactable islay
    :repeatable T
    :title (@ shop-sell-items)
    :dialogue "! eval (show-sales-menu :sell 'islay)")))
