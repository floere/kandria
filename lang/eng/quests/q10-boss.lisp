;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q10-boss)
  :author "Tim White"
  :title ""
  :visible NIL
  (:go-to (q10-mechs) :marker NIL)
  (:eval
   (override-music 'battle))
  (:complete (q10-boss-fight))
  (:eval
   (override-music NIL))
  (:wait 1)
  (:interact (NIL :now T)
  "
~ player
| \"That's one less mech to worry about. Not that it will make much difference with this many.\"(light-gray, italic)
| (:thinking)\"They built this from drills and turbines. Perhaps I can verify what its purpose is.\"(light-gray, italic)
| (:normal)\"There's an interface port.\"(light-gray, italic) (:giggle)\"Just gotta stick my finger in here... Pardon me.\"(light-gray, italic)
| (:normal)\"Hang on, what's this?\"(light-gray, italic)
| \"Investigate possibility of additional android acquisitions: \"Genera\"(red) in the \"western mountains\"(red).\"
| (:thinking)\"... A faction of androids, in the mountains?\"(light-gray, italic)
| \"I'm not alone?\"(light-gray, italic)
? (complete-p (find-task 'q10-wraw 'wraw-warehouse))
| | (:embarassed)\"Anyway: given the raw materials I saw in the warehouse, their manufacturing ambitions are __HUGE__.\"(light-gray, italic)
| | (:normal)\"As in \"invading the entire valley\"(orange) huge - from the mountains to the coast.\"(light-gray, italic)
| | \"I need to \"contact Fi\"(orange).\"(light-gray, italic)
| | \"... \"FFCS can't punch through\"(orange) - it's either magnetic interference from the magma, or the \"Wraw are on the move\"(orange).\"(light-gray, italic)
| | \"I'd better \"get out of here\"(orange) and \"deliver my report\"(orange).\"(light-gray, italic)
| ! eval (complete (find-task 'q10-wraw 'wraw-objective))
| ! eval (activate 'q10a-return-to-fi)
| ! eval (activate (unit 'wraw-border-1))
| ! eval (activate (unit 'wraw-border-2))
| ! eval (activate (unit 'wraw-border-3))
| ! eval (activate (unit 'station-east-lab-trigger))
| ! eval (activate (unit 'station-cerebat-trigger))
| ! eval (activate (unit 'station-semi-trigger))
| ! eval (activate (unit 'station-surface-trigger))
|?
| | \"I'd better \"finish exploring this region\"(orange). Hopefully there'll be no more surprises.\"(light-gray, italic)
"))