#lang racket/gui

(define appname "RacketPad")
(define openfilename #f)
(define getopenfilename (lambda () (if (equal? #f openfilename) 
                                       "Untitled" 
                                       openfilename)))

(define setopenfile (lambda (filename)
                      (set! openfilename filename)
                      (send f set-label (string-append (getopenfilename) " - " appname))))

; Top-level window
(define f (new frame% [label "Untitled - RacketPad"]
                      [width 800] [height 600]))

; Editor stuff
(define c (new editor-canvas% [parent f]))
(define t (new text%))
(define m (new menu-bar% [parent f]))

; Callbacks

(define save-file-as (lambda (mi ce)
                       (setopenfile 
                        (path->string
                         (put-file "Open File" f #f #f "txt" null '(("Any" "*.*")))))
                         (send t save-file openfilename (send t get-file-format) #t)))

(define save-file (lambda (mi ce)
                    (send t save-file openfilename (send t get-file-format) #t)))

(define new-file (lambda (mi ce)
                   (setopenfile "Untitled")
                   (send t erase)))

(define open-file (lambda (mi ce)
                    (setopenfile (path->string
                         (get-file "Open File" f #f #f "txt" null '(("Any" "*.txt")))))
                    (send t load-file (string->path openfilename))))

(define undo (lambda (mi ce) (send t undo)))
(define cut (lambda (mi ce) (send t do-edit-operation 'cut)))
(define paste (lambda (mi ce) (send t do-edit-operation 'paste)))
(define delete (lambda (mi ce) (send t do-edit-operation 'kill)))

; Menu
(define fm (new menu% [label "File"] [parent m]))

(define fnew (new menu-item% [label "New"] [parent fm] [callback new-file]))
(define fopen (new menu-item% [label "Open"] [parent fm] [callback open-file]))
(define fsaveas (new menu-item% [label "Save As"] [parent fm] [callback save-file-as]))
(define fsave (new menu-item% [label "Save"] [parent fm] [callback save-file]))

(define em (new menu% [label "Edit"] [parent m]))
(define eundo (new menu-item% [label "Undo"] [parent em] [callback undo]))
(define ecut (new menu-item% [label "Cut"] [parent em] [callback cut]))
(define epaste (new menu-item% [label "Paste"] [parent em] [callback paste]))
(define edel (new menu-item% [label "Delete"] [parent em] [callback delete]))

((current-text-keymap-initializer)
 (send t get-keymap))

(send t set-max-undo-history 'forever)

(send c set-editor t)
(send f show #t)