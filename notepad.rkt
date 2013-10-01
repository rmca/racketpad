#lang racket/gui

(define appname "RacketPad")
(define openfilename #f)
(define (getopenfilename) 
  (if (equal? #f openfilename) 
      "Untitled" 
      openfilename))

(define (setopenfile filename)
  (set! openfilename filename)
  (send f set-label (string-append (getopenfilename) " - " appname)))

(define wordwrapping #f)

; Top-level window
(define f (new frame% [label "Untitled - RacketPad"]
                      [width 800] [height 600]))

; Editor stuff
(define c (new editor-canvas% [parent f]))
(define t (new text%))
(define m (new menu-bar% [parent f]))

; Callbacks

(define (save-file-as mi ce)
  (setopenfile 
   (path->string
    (put-file "Open File" f #f #f "txt" null '(("Any" "*.*")))))
  (send t save-file openfilename 'text #t))

(define (save-file mi ce)
  (if (equal? #f openfilename)
      (save-file-as mi ce)
      (send t save-file openfilename (send t get-file-format) #t)))

(define (new-file mi ce)
  (setopenfile "Untitled")
  (send t erase))

(define (open-file mi ce)
  (setopenfile (path->string
                (get-file "Open File" f #f #f "txt" null '(("Any" "*.txt")))))
  (send t load-file (string->path openfilename)))

(define (wordwrap mi ce)
  (set! wordwrapping (not wordwrapping))
  (send t auto-wrap wordwrapping))

(define (selectfont mi ce) (get-font-from-user "Font" f))

; Menu
(define fm (new menu% [label "File"] [parent m]))
(define fnew (new menu-item% [label "New"] [parent fm] [callback new-file] [shortcut #\n]))
(define fopen (new menu-item% [label "Open"] [parent fm] [callback open-file] [shortcut #\o]))
(define fsaveas (new menu-item% [label "Save As"] [parent fm] [callback save-file-as]))
(define fsave (new menu-item% [label "Save"] [parent fm] [callback save-file] [shortcut #\s]))

(define em (new menu% [label "Edit"] [parent m]))
(append-editor-operation-menu-items em)

(define fmm (new menu% [label "Format"] [parent m]))
(define fww (new menu-item% [label "Word Wrap"] [parent fmm] [callback wordwrap]))

((current-text-keymap-initializer)
 (send t get-keymap))

(send t set-max-undo-history 'forever)

(send c set-editor t)
(send f show #t)