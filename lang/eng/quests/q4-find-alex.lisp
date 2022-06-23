;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-find-alex)
  :author "Tim White"
  :title "Find Alex"
  :description "Fi wants me to find Alex and bring them back to Camp for debriefing, to see if they know anything about the Wraw's plans. Their last known location was Cerebat territory, deep underground. I should avoid the Semi Sisters en route."
  :on-activate (find-alex-reminder find-alex find-alex-cerebats)

  (find-alex-reminder
   :title ""
   :visible NIL
   :condition (complete-p 'find-alex)
   :on-activate (q4-reminder)

   (:interaction q4-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
? (not (complete-p 'find-alex-cerebats))
| | Go to the \"Cerebats township deep underground, find Alex and bring them back\"(orange) for debriefing.
| | Watch out for the Semi Sisters on your way. They're not our enemies, but they are unpredictable.
|?
| | (:unsure)Alex isn't with the Cerebats? That is worrying.
| | (:normal)Well they still haven't returned. I suggest you \"search the tunnels between the Semis and the Cerebats\"(orange).
| | I hope they're okay.
"))

  (find-alex
   :title "Find Alex"
   :condition (or (complete-p 'innis-stop-local) (complete-p 'innis-stop-remote))
   :on-activate NIL
   :on-complete NIL

   (:interaction innis-stop-local
    :interactable innis
    :dialogue "
~ innis
| (:angry)<-STOP-> WHERE YOU ARE!
| Did you think ya could just waltz right through here?
| (:sly)We've been watching you, android. You and your wee excursions with Catherine.
| And now you've come to visit us. How thoughtful.
~ player
- Who are you?
  ~ innis
  | Alas, no' too smart...
- What do you want?
  ~ innis
  | (:sly)I'll ask the questions if ya dinnae mind.
- Are you the Semi Sisters?
  ~ innis
  | (:sly)I'll ask the questions if ya dinnae mind.
~ innis
| (:sly)What //should// we do with you? I bet your \"Genera core\"(red) could run our entire operation.
| What do you think, \"Islay\"(yellow)?
! eval (setf (nametag (unit 'islay)) (@ islay-nametag))
~ islay
| (:unhappy)I think you should leave her alone.
~ innis
| (:angry)...
| (:normal)Come now, sister - the pinnacle of human engineering is standing before you, and that's all you can say?
| (:sly)That wasn't a compliment by the way, android. (:normal)But let's no' get off on the wrong foot now.
~ player
- My name's Stranger.
  ~ innis
  | This I ken, android. (:sly)Tell me, why are you here?
- (Keep quiet)
  ~ innis
  | (:sly)Why are you are here? I ken lots about you, but I want more.
~ innis
| (:sly)What //does// Fi send her robot dog to do?
| To prove her loyalty, I think.
~ player
- My business is my business.
  ~ innis
  | If that's your prerogative.
  | But you'll be pleased to ken that \"Alex is here\"(orange).
- I'm looking for someone called Alex, have you seen them?
  ~ innis
  | (:sly)You see, sister, the direct approach once again yields results - and confirms my information.
  | (:normal)You'll be pleased to ken that \"Alex is here\"(orange).
- Go fuck yourself.
  ~ islay
  | ...
  ~ innis
  | (:angry)...
  | I remember your kind! You think you're clever just 'cause you can mimic us.
  | You're a machine, and if I wanted I could have you pulled apart and scattered to the four corners of this valley.
  | (:normal)Now, let's try again.
  | You'll be pleased to ken that the one you seek, \"Alex, is here\"(orange).
~ innis
| Indulge me, would you? I want to see how smart you are.
| See if you can \"find them\"(orange) for yourself.
! eval (deactivate 'innis-stop-remote)
! eval (deactivate (unit 'innis-stop-2))
! eval (deactivate (unit 'innis-stop-3))
! eval (deactivate (unit 'innis-stop-4))
! eval (deactivate (unit 'innis-stop-5))
! eval (deactivate (unit 'innis-stop-6))
! eval (deactivate (unit 'innis-stop-semi-station))
! eval (activate 'find-alex-semis)
? (active-p 'find-alex-cerebats)
| ! eval (deactivate 'find-alex-cerebats)
| ! eval (deactivate (unit 'player-stop-cerebats))
? (active-p 'find-alex-semis-route)
| ! eval (deactivate 'find-alex-semis-route)
")
#|
dinnae = don't (Scottish)
ken = know (Scottish)
|#

   (:interaction innis-stop-remote
    :interactable innis
    :dialogue "
~ innis
| (:angry)<-STOP-> WHERE YOU ARE!
| Did you think ya could just waltz right through here?
| (:sly)We've been watching you, android. You and your wee excursions with Catherine.
| And now you've come to visit us. How thoughtful.
! label questions
~ player
- Who are you?
  ~ innis
  | (:sly)You'll find out soon enough.
- Where are you?
  ~ innis
  | (:sly)Close by.
- What do you want?
  ~ innis
  | (:sly)I'll ask the questions if ya dinnae mind.
- Are you the Semi Sisters?
  ~ innis
  | (:sly)I'll ask the questions if ya dinnae mind.
~ innis
| (:sly)What //should// we do with you? I bet your \"Genera core\"(red) could run our entire operation.
| What do you think, \"Islay\"(yellow)?
! eval (setf (nametag (unit 'islay)) (@ islay-nametag))
~ islay
| (:unhappy)I think you should leave her alone.
~ innis
| (:angry)...
| (:normal)Come now, sister - you're speaking with the pinnacle of human engineering, and that's all you can say?
| (:sly)That wasn't a compliment by the way, android. (:normal)But let's no' get off on the wrong foot now.
~ player
- My name's Stranger.
  ~ innis
  | This I ken, android. (:sly)Tell me, why are you here?
- (Keep quiet)
  ~ innis
  | (:sly)Why are you are here? I ken lots about you, but I want more.
~ innis
| (:sly)What //does// Fi send her robot dog to do?
| To prove her loyalty, I think.
~ player
- My business is my business.
  ~ innis
  | If that's your prerogative.
  | But you'll be pleased to ken that \"Alex is here\"(orange).
- I'm looking for someone called Alex, have you seen them?
  ~ innis
  | (:sly)You see, sister, the direct approach once again yields results - and confirms my information.
  | (:normal)You'll be pleased to ken that \"Alex is here\"(orange).
- Go fuck yourself.
  ~ islay
  | ...
  ~ innis
  | (:angry)...
  | I remember your kind! You think you're clever just 'cause you can mimic us.
  | You're a machine, and if I wanted I could have you pulled apart and scattered to the four corners of this valley.
  | (:normal)Now, let's try again.
  | You'll be pleased to ken that the one you seek, \"Alex, is here\"(orange).
~ innis
| Indulge me, would you? I want to see how smart you are.
| See if you can \"find them\"(orange) for yourself.
~ player
| \"She's gone. That was an FFCS broadcast, from somewhere nearby.\"(light-gray, italic)
| \"That means \"Alex is close\"(orange). Unless it's a trap.\"(light-gray, italic)
! eval (deactivate 'innis-stop-local)
! eval (deactivate (unit 'innis-stop-1))
! eval (deactivate (unit 'innis-stop-2))
! eval (deactivate (unit 'innis-stop-3))
! eval (deactivate (unit 'innis-stop-4))
! eval (deactivate (unit 'innis-stop-5))
! eval (deactivate (unit 'innis-stop-6))
! eval (deactivate (unit 'innis-stop-semi-station))
! eval (activate 'find-alex-semis)
? (active-p 'find-alex-cerebats)
| ! eval (deactivate 'find-alex-cerebats)
| ! eval (deactivate (unit 'player-stop-cerebats))
? (active-p 'find-alex-semis-route)
| ! eval (deactivate 'find-alex-semis-route)
"))
#|
dinnae = don't (Scottish)
ken = know (Scottish)
|#

  (find-alex-cerebats
   :title ""
   :marker '(chunk-5526 2200)
   :visible NIL
   :condition all-complete
   :on-activate NIL
   :on-complete (find-alex-semis-route)

   (:interaction player-stop-cerebats
    :interactable player
    :dialogue "
~ player
| \"I don't think Alex is here.\"(orange, italic)
| (:thinking)\"Perhaps I missed them en route - I should \"follow the path back up towards the Semi Sisters\"(orange).\"(light-gray, italic)
"))

  (find-alex-semis-route
   :title "Alex isn't in Cerebats territory - follow the path back up towards the Semi Sisters"
   :condition NIL
   :on-activate NIL
   :on-complete NIL)

#|
TODO: IDEA: while find-alex-semis is active, enable NPCs in the Semis area to be questionined if they are Alex, as a variant on their world-building dialogue.
|#
  (find-alex-semis
   :title "Search near the woman that stopped me for any sign of Alex"
   :marker '(chunk-5628 1800)
   :description NIL
   :invariant T
   :condition (complete-p 'alex-meet)
   :on-activate (islay-hint alex-meet)
   :on-complete (q5-run-errands)

   (:interaction islay-hint
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
| Hello, Stranger. It's an honour to meet you in person.
| (:unhappy)I'm sorry about my sister.
| (:nervous)If you're looking for \"Alex, try the bar\"(orange). It's \"on the level above us\"(orange).
| Just don't tell \"Innis\"(yellow) I told you. She'll think I've gone soft for androids.
! eval (setf (nametag (unit 'innis)) (@ innis-nametag))
! eval (setf (var 'android-soft) T)
")


   (:interaction alex-meet
    :interactable alex
    :dialogue "
~ player
| \"This person's breath smells like diesel mixed with seaweed.\"(light-gray, italic)
~ alex
| (:unhappy)What you looking at? <-Hic->.
~ player
- Alex?
- (Lie) I wasn't looking at you.
  ~ alex
  | (:unhappy)Goes away then.
  ~ player
  | Are you Alex?
- A drunk in a bar.
  ~ alex
  | (:angry)'Ow dare you.
  ~ player
  | Are you Alex?
~ alex
| (:unhappy)I ain't Alice.
~ player
| I said \"Alex\" not \"Alice\".
~ alex
| <-Hic->. That's what I said.
~ player
| Oh boy.
| Are you Alex from the Noka? Do you know Fi?
~ alex
| ...
| Yeah that's me. <-Hic->.
! eval (setf (nametag (unit 'alex)) (@ alex-nametag))
~ player
- My name is Stranger.
  ~ alex
  | (:unhappy)<-Hic->. I know. You're the new hunter.
  | The android.
- Fi sent me.
  ~ alex
  | (:unhappy)<-Hic->. I know. You're the new hunter.
  | The android.
- I'm an android.
  ~ alex
  | (:unhappy)You wanna medal? <-Hic->. I know who you are. You're the new hunter.
~ alex
| (:unhappy)Lemme save you some trouble. I ain't going back.
~ player
- Why not?
  ~ alex
  | (:unhappy)You really gotta ask that?
  | ...
  | (:angry)Alright, you asked for it: <-Hic->. You're the reason.
- It's important that you do.
  ~ alex
  | No it ain't. Far from it.
~ alex
| (:angry)I've 'eard about you, doing my job- <-Hic->.
| \"Innis\"(yellow) even showed me the CCCTV. Semi Sisters been nice to me.
! eval (setf (nametag (unit 'innis)) (@ innis-nametag))
| So why would Fi need little ol' me any more?
| Run along matey - <-hic-> - an' tell her to spin on that, why dontcha?
~ player
| Do you know about the Wraw's plan to attack?
~ alex
| They're always planning to attack. <-Hic->. This just Fi getting her knickers in a twist again.
| (:unhappy)<-Hic->. Speaking o' twists, can't a geezer get a refill 'round 'ere? __BARKEEP!__
~ player
| \"They're not going to get anyone's attention like that.\"(light-gray, italic) (:embarassed)\"Oh great, now the the barkeep's scowling at me too.\"(light-gray, italic)
~ player
- (Buy Alex another drink - 40)
  ? (<= 40 (item-count 'item:parts))
  | ! eval (retrieve 'item:parts 40)
  | ~ alex
  | | Ugh, thansssks. <-Hic->.
  | ~ player
  | | \"Wow, they downed it in one.\"(light-gray, italic)
  | | (:embarassed)\"Are they going to throw up?!... I need to move.\"(light-gray, italic) (:normal)\"Oh, they swallowed it back down. Lovely.\"(light-gray, italic)
  | | \"I'm glad that can't happen to androids.\"(light-gray, italic)
  |?
  | ~ player
  | | (:embarassed)\"I don't have enough scrap for that. I didn't think the barkeep's brow could furrow any more, but it has.\"(light-gray, italic)
- (Buy Alex a soft drink - 20)
  ? (<= 20 (item-count 'item:parts))
  | ! eval (retrieve 'item:parts 20)
  | ~ alex
  | | (:unhappy)This ain't booze! What am I suppossed to do wiv this? <-Hic->.
  | ~ player
  | | \"Oh, they're drinking it anyway.\"(light-gray, italic)
  |?
  | ~ player
  | | (:embarassed)\"I don't have enough scrap for that. I didn't think the barkeep's brow could furrow any more, but it has.\"(light-gray, italic)
- (Leave them be)
~ player
| \"Whoa, Alex nearly fell over. I'm not sure they can see straight. Ah, now they're looking at me again.\"(light-gray, italic)
~ alex
| You're a stenacious one, aren't ya? <-Hic->.
~ player
- Did you learn anything from the Cerebats?
  ~ alex
  | I learned where all the tunnels go. <-Hic->. Mapped that whole area, an' the one below that.
- Where have you been all this time?
  ~ alex
  | 'Ere, mostly.
  | Oh, an' I mapped this whole area, an' the ones below that.
~ player
| Those maps could really help me.
~ alex
| (:angry)You mad? I give you these an' I really would have nuffin'. <-Hic->.
| Now get lost.
| (:normal)Actually, before you go: Did you know it was me that found you? <-Hic->. I told Catherine where you were.
| I was just walking along an' there you were. Exposed by an earthquake I reckon. <-Hic->. I pulled you outta the rubble.
| (:angry)Now I wish I'd kept my mouth shut an' smashed you up instead.
! eval (deactivate 'islay-hint)
")))