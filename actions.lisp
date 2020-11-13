(in-package #:org.shirakumo.fraf.kandria)

(define-action editor-command ())

(define-action toggle-editor (editor-command))
(define-action toggle-diagnostics (editor-command))
(define-action screenshot (editor-command))
(define-action report-bug (editor-command))

(define-action undo (editor-command)
  (key-press (and (one-of key :z)
                  (retained :control))))

(define-action redo (editor-command)
  (key-press (and (one-of key :y)
                  (retained :control))))

(define-action menuing ())
(define-action skip (menuing))
(define-action advance (menuing))
(define-action previous (menuing))
(define-action next (menuing))
(define-action accept (menuing))
(define-action back (menuing))
(define-action pause (menuing))
(define-action quicksave (menuing))
(define-action quickload (menuing))
(define-action movement ())
(define-action interact (movement))
(define-action jump (movement))
(define-action dash (movement))
(define-action crawl (movement))
(define-action light-attack (movement))
(define-action heavy-attack (movement))
