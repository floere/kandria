(:name task-return-home
 :title "Return to the settlement and talk to Catherine"
 :description "Catherine repaired the sabotaged pipe and headed back. I should return to the engineering building and speak with her."
 :invariant T
 :condition all-complete
 :on-activate (catherine-return)
 :on-complete NIL)

;; REMARK: I don't like the examination part. I don't think it's reasonable to assume that Catherine
;;         would know how to scan through those logs, given that she didn't even grow up before the calamity,
;;         and there's very little if any information on them out there, let alone how to maintain them.
;;         I think it would be much more reasonable if Catherine starts looking around for a way to interface
;;         with her, perhaps referencing something like "If we had a functioning computer maybe we could
;;         connect to her through some kinda data port..." but then fails to even find such a port.
;;         
;;         As for how she reactivated the stranger, I think something simple like applying pressure on her
;;         earlobe would work, rather than requiring any deep interfacing, and the way she discovered that
;;         was mostly dumb luck and curiosity, more than anything.
(quest:interaction :name catherine-return :interactable entity-5339 :dialogue "
~ catherine
| Hey, Stranger - See what'd I tell you?
| Jack here didn't think you'd come back.
~ jack
| This don't prove a thing.
~ fi
| You've done well, Catherine. An android is a great asset for us.
| Assuming it can be trusted.
~ catherine
| I don't understand...
~ fi
| Is it not coincidental that you discovered it at the same time as our water supply was sabotaged?
~ catherine
| But we saw the rogues - they were smashing the pipes!
~ jack
| Maybe this android can control them? Did you think of that?
~ catherine
| ...
| Androids do have far-field comms systems...
| Theoretically, something like that could penetrate deeper underground than our radios.
| But no, it's not that. She was offline for decades - there's no way she could have done that.
| And since I brought her online, she's been with me the whole time! She can't have betrayed us.
~ jack
| But what do we really know about androids, Cathy? Fuck all, that's what.
~ catherine
| Well, ask her. Have you betrayed us, Stranger?
- No I have not.
  ~ catherine
  | There, see.
  ~ fi
  | Alright - well, let's hope it's telling the truth. If not, then the Wraw know our location, and their hunting parties are already on their way.
- I don't think I have.
  ~ catherine
  | Her memories are all muddled from before I brought her online. She hasn't, trust me.
  ~ fi
  | Alright - well, let's hope that's true. If not, then the Wraw know our location, and their hunting parties are already on their way.
- I suppose I could have - but I don't remember.
  ~ catherine
  | She doesn't know what she's saying - her memories are all screwed up till the point I brought her online.
  ~ fi
  | Alright - it's hardly conclusive, but for now we'd better hope it's telling the truth.
  | If not, then the Wraw know our location, and their hunting packs are already on their way.
~ jack
| Jesus, Fi... you're just gonna take that at face value?
~ fi
| What choice do I have?
~ jack
| Examine the thing, find out for sure.
~ fi
| Catherine, can it be done?
~ catherine
| I guess I could check her black box, see if the FFCS was active lately.
| But I think we should ask HER if that is okay.
~ fi
| You're right, Catherine. I'm sorry...
| Stranger, wasn't it.
~ jack
| ...
~ fi
| Would you permit Catherine to examine you? For our own peace of mind?
~ player
- I'd rather she didn't.
  ~ fi
  | It's your choice, of course.
  ~ jack
  | Really? You're gonna let this thing call the shots?
  ~ fi
  | This \"thing\" is a person, Jack. And I expect you to treat her as such.
  | I trust Catherine's judgement. For now, Stranger is our guest.
- Sure, why not.
  < examine
- As long as I'm still online afterwards.
  ~ catherine
  | Don't worry. I won't let them turn you off.
  < examine
> continue
~ fi
| But irrespective of all this, I am certain that the Wraw are our attackers.
| Which means they're close to discovering our location one way or another.
| I must consider our next course of action.
~ catherine
| Well, if there's nothing else, I'll see you both later.
| Hey Stranger, wait here - I want to talk.
~ fi
| Sayonara Catherine, Stranger.
~ jack
| You take care, Cathy.
! eval (setf (location 'fi) 'entity-5437)
! eval (move-to 'entity-5436 (unit 'jack))
! eval (activate 'catherine-trader)

# examine
~ fi
| Thank you. Catherine, if you could proceed.
~ catherine
| This won't hurt a bit.
~ player
| //Catherine takes my right forearm and opens up an access panel. A strange sensation - I can no longer feel my skin in that area.//
~ catherine
| Nope, just like I said: her log is clean.
| If those rogue's were remote-controlled, the signal didn't come from her.
~ jack
| You sure, Cathy?
~ catherine
| Positive.
~ fi
| I am satisfied, for now. Thank you Catherine, Stranger.
< continue
")
;; TODO: restore when fi has animations: ! eval (move-to 'entity-5437 (unit 'fi))
;; TODO: jack move not working (and no error)

#| DIALOGUE REMOVED FOR TESTING



|#
;; REMARK: Maybe say "adults" instead? "Grown-ups" sounds too child-like.
(quest:interaction :name catherine-trader :interactable catherine :dialogue "
~ catherine
| Urgh, grown-ups. I mean, I'm technically a grown-up, but not like those dinosaurs.
| Oh! I almost forgot: It's our way to gift something to those that help us out.
| Since those two aren't likely to be feeling generous anytime soon, I'll give you these.
! eval (store 'small-health-pack 3)
| It's not much, but you can trade them for things you might want. Or you will once Sahil gets here.
| He's overdue, which is not like him at all. Maybe those rogues scared him off.
| Anyway, I've got work to do. Feel free to have a look around, get to know people.
| They'll soon see what I see - a big friendly badass, who can protect us from harm.
| I think Fi might want a private word with you too. Just a hunch... something about the way she was looking at you.
| Knowing Jack, he'll have something for you to do as well.
| Seeya later!
! eval (move-to 'entity-5436 (unit 'catherine))
! eval (activate 'q2-intro)
! eval (activate 'q3-intro)
")

;; TODO: rewards - is only storing +1 and no notification too: ! eval (store 'small-health-pack 3)
;; Let's not have catherine go to trader as well - player needs some time away from Catherine (which helps by delaying the trader arrive till after quest 2/3)
;; Activate people quest 2/3/hub

#|



|#

;; Catherine got the android online, so she must know the basics about them
;; also, don't want to have to go to the lab and do this, as too much travelling back and fourth (fetch quests) - and besides, player could run off

#| todo too much exposition too soon... This should be at the end of Act 1?...
| Indeed, allow me to formally welcome you to the Noka.
| We don't have much, but we hope you'll be comfortable here.
| Just please understand that times are hard, and
| And please bear with us - it will be more difficult for some of us than others to have an android around the camp.
|#


;; TODO: Explain Wraw yet? Hold off for quest 2/3? Say they have androids for parts/slave labour? Use them as electronic power supplies?
;; TODO: also later make reference to the stranger's clothes e.g. Jack: "And what is it wearing? I've never seen anything like it." Catherine: "I don't know but I love it! They're not clothes like ours either, she's just sort of made that way."
