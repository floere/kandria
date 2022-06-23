;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO update this dialogue with chat options once been to the Semis in act 2? It seems reasonable Catherine would want to catch up (not Jack, and Fi's catchup is handled in the main questline); also the Semis mention Catherine by name...
(quest:define-quest (kandria sq-act1-intro)
  :author "Tim White"
  :title "Talk to Catherine"
  :description "I should catch up with Catherine, see if she needs anything doing."
  :on-activate T
  :variables (asked-leaks)
  
  (sq-act1-catherine
   :title "Talk to Catherine in Engineering"
   :marker '(catherine 500)
   :invariant (not (complete-p 'q10-wraw))
   :condition all-complete
   :on-activate T
   (:interaction talk-catherine
    :title "Hi Catherine."
    :interactable catherine
    :dialogue "
~ catherine
| Hey, Stranger. How are you?
~ player
- Can I help out?
  < choices
- It's nice to see you again.
  ~ catherine
  | I wish we could spend more time together.
  < continue
- Good. How are you?
  ~ catherine
  | Me? Oh, same as always. (:concerned)Jack's as overbearing as ever, but I can take it.
  | (:normal)I think if I can just keep my head down and keep doing something, then I won't worry about the future. Or the past.
  | Just take it day by day, you know?
  < continue
- I'm feeling low.
  ~ catherine
  | (:concerned)Oh no... I'm sorry. People are mean, I don't understand why.
  | Anyone that's different, they've already made up their minds about them.
  | (:normal)You just keep being you. I'll talk to them, I promise.
  < continue

# continue
~ player
| Can I help out?
! label choices
~ catherine
| You are strangely perceptive... (:excited)Man I'd love to understand how your core works.
| (:normal)The \"water pressure is off again\"(orange), so you could help with that.
? (<= 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:normal)I was going to say we need some \"mushrooms, what with food stocks running out\"(orange).
| | (:excited)But is it me, or are those \"mushrooms you're carrying\"(orange)?
| | (:excited)You're very proactive, Stranger, I like that! Let's see what you've got.
| ? (have 'item:mushroom-good-1)
| | | (:excited)\"Flower fungus\"(red), nice! I'll get these to Fi and straight into the cooking pot.
| | | (:normal)Apparently if you eat them raw they'll give you the skitters. One day I'll test that theory.
| | ! eval (retrieve 'item:mushroom-good-1 T)
| ? (have 'item:mushroom-good-2)
| | | (:cheer)\"Rusty puffball\"(red), great! These are my favourite - I made my neckerchief from them, believe it or not.
| | | (:normal)I weaved them together with synthetic scraps; I needed a mask so their spores wouldn't give me lung disease.
| | ! eval (retrieve 'item:mushroom-good-2 T)
| ? (have 'item:mushroom-bad-1)
| | | (:disappointed)Oh, \"black cap\"(red)... Not a lot I can do with poisonous ones.
| | | (:normal)Don't worry, I'll burn them later - don't want anyone eating them by accident.
| | ! eval (retrieve 'item:mushroom-bad-1 T)
|  
| | (:normal)You know, it might not seem like much, but hauls like these could be the difference between us making it and not making it.
| | We get birds, fish and bats when we can too, but they're harder to catch. Mushrooms don't run away.
| | (:cheer)We owe you big time. Here, \"take these parts\"(orange), you've definitely earned them.
| ! eval (store 'item:parts 300)
| | (:normal)If you \"find any more mushrooms\"(orange), make sure you grab them.
| | If we don't need them, the least you could do is \"trade them with Sahil\"(orange).
| ! eval (complete 'sq2-mushrooms)
|?
| | (:normal)With food stocks running out, Fi wants to \"forage for more mushrooms\"(orange). They're good for clothing too.
| | I'd say at least \"25 puffballs or flower fungus\"(orange) should do. \"Avoid black caps\"(orange) though.
  
| (:excited)Oh, I've been speaking with my friends - we're all eager to see what you're really capable of.
| How do \"time trial races\"(orange) sound, eh?
| (:normal)Basically we've planted \"beer cans for you to find and bring back\"(orange). (:excited)The \"faster you can do it, the more parts you'll get\"(orange)!
| So there you go - lots to do, if you fancy it. You want any more info?
! label task-choice
~ player
- (Ask about the leaks)
  ~ catherine
  | Sure thing. I've secured the pump now, so I'm pretty sure it's \"just a few leaks\"(orange). (:concerned)Hopefully the saboteurs aren't back.
  ? (not (var 'asked-leaks))
  | | (:normal)Androids can weld from their fingertips, right?
  | ~ player
  | - I can do that?
  |   ~ catherine
  |   | I'm pretty sure you can. Try it out.
  |   ~ player
  |   | (:giggle)\"She's right. I thought about it, and now a small welding torch is glowing from the index finger on my right hand. It tickles.\"(light-gray, italic)
  |   | (:normal)\"Better keep the intensity low, so as not to blind us.\"(light-gray, italic)
  |   ~ catherine
  |   | (:excited)See!
  |   ~ player
  |   - Cool!
  |   - I forgot I could do that.
  |     ~ catherine
  |     | Don't worry.
  |   - Need a light?
  |     ~ catherine
  |     | Sorry, I don't smoke.
  | - That's right.
  |   ~ catherine
  |   | (:excited)Can I see?
  |   ~ player
  |   | \"She looks impressed. I suppose a welding torch glowing from the tip of someone's finger isn't the most common sight around here.\"(light-gray, italic)
  |   | \"Better keep the intensity low, so as not to blind us.\"(light-gray, italic)
  |   ~ catherine
  |   | (:excited)That's so cool!
  | - Where did you hear that?
  |   ~ catherine
  |   | It's just one of those things I know about androids. (:excited)Why, is it a big secret?
  |   | Let me see!
  |   ~ player
  |   | \"She looks impressed. I suppose a welding torch glowing from the tip of someone's finger isn't the most common sight around here.\"(light-gray, italic)
  |   | \"Better keep the intensity low, so as not to blind us.\"(light-gray, italic)
  |   ~ catherine
  |   | (:excited)That's so cool!
  | | (:normal)Okay, I think you're good to go.
  | ! eval (setf (var 'asked-leaks) T)
    
  | (:normal)Just \"follow the red pipeline\"(orange) down like we did before.
  | Judging from the pressure drop, these leaks \"aren't too far away\"(orange), so you'll be within radio range.
  ~ player
  | \"My FFCS indicates \"3 leaks\"(orange), close to the surface as Catherine said.\"(light-gray, italic)
  < task-choice
- [(not (complete-p 'sq2-mushrooms)) (Ask about the mushrooms)|]
  ~ catherine
  | They grow in the \"caves beneath Camp\"(orange), in the dim light and moisture there.
  | Edible mushrooms like the \"flower fungus\"(orange) can sustain us even if the crop fails.
  | They're all we used to eat before we moved to the surface.
  | Fibrous ones like the \"rusty puffball\"(orange) can be used to weave clothing. 
  | We combine them with recycled synthetic clothes from the old world - like yours - and pelts from animals we hunt.
  | Just don't breathe in their spores - though I doubt they will affect you.
  | Other kinds are deadly poisonous, like the \"black cap - avoid those if you can\"(orange).
  | At least \"25 puffballs or flower fungus\"(orange) should suffice for now. (:excited)Happy mushrooming, Stranger!
  < task-choice
- (Ask about the time trials)
  ~ catherine
  | (:excited)Heh, I knew that would intrigue you. I can't wait to see what an almost-fully-functional android can do!
  | (:normal)So yeah, we've planted old-world \"beer cans around the area for you to find and return\"(orange).
  | I'll \"record your times\"(orange) for posterity - this is anthropology! The \"faster you are, the more parts you'll get from the sweepstake\"(orange).
  | Once you've \"completed one I can tell you about the next route\"(orange). Them's the rules.
  | (:excited)Just \"tell me when you want to start\"(orange), and we'll get this show on the road.
  | (:cheer)This is sooo exciting!  
  < task-choice
- I'm ready.
  ~ catherine
  | (:excited)Well alright.
  < end

# end
~ catherine
| You can handle yourself, but check in if you feel the need. You want to \"take a walkie, or just use your FFCS\"(orange)? - It will work with our radios.
~ player
- I'll take a walkie.
  ~ catherine
  | You got it - take this one.
  ! eval (store 'item:walkie-talkie 1)
  ! eval (setf (var 'take-walkie) T)
- My FFCS will suffice.
  ~ catherine
  | You got it.
~ catherine
| \"Let me know if you need more info\"(orange) - and \"if you want to start a time trial\"(orange).
| (:excited)Good luck!
! eval (activate 'sq1-leaks)
? (not (complete-p 'sq2-mushrooms))
| ! eval (activate 'sq2-mushrooms)
  
! eval (activate 'sq3-race)
")))
;; "We get birds and fish when we can too" meaning they hunt them themselves now they can, living on the surface; but they also trade them with sahil from time to time
;; tasks get added to journal in one fell swoop (player did ask) - but they're sidequests, so they don't have to do them
