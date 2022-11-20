;;; md4rd-test.el --- Tests -*-lexical-binding:t-*-


(require 'buttercup)
(require 'ansi-color)

(require 'md4rd)

(cl-defun test--fetch-sub-callback (sub &rest data &allow-other-keys)
  "Callback for async, DATA is the response from request."
  (let ((my-data (plist-get data :data)))
    (expect t :to-be nil)
  )
)

(describe "A non-related (general emacs) suite"
  (it "gets string from JSON on the web"
    (let (json)
      (request
        "https://api.github.com/status"
        :parser #'json-read
        :success (cl-function
                  (lambda (&key data &allow-other-keys)
                    (setq json data)))
        :sync t)
      (let ((message-string (cdr (assoc 'message json))))
      (message (substring message-string 0 13))
      (expect (substring message-string 0 13) :to-equal "GitHub lives!")
      )
    )
))

(describe "A set of helpers in md4rd"
  (it "formats sub URL properly"
      (expect (format md4rd--sub-url 'emacs) :to-equal "https://www.reddit.com/r/emacs.json")
  )

  (it "formats sub pairs for URL properly"
      (expect (md4rd--get--url '(emacs sub)) :to-equal "https://www.reddit.com/r/emacs.json")
      (expect (md4rd--get--url '("https://www.reddit.com/r/emacs2.json" fullurl)) :to-equal "https://www.reddit.com/r/emacs2.json")
      (should-error (md4rd--get--url '("https://www.reddit.com/r/emacs2.json" aaa)))
  )

  (it "formats defined variables of sub pairs for URL properly"
      (let (
            (mysubs (append
                     (mapcar (lambda (subsingle) (cons subsingle (cons 'sub nil))) md4rd-subs-active)
                     (mapcar (lambda (subpair) (cons (car subpair) (cons 'fullurl (cons (cadr subpair) nil)))) md4rd-customurls-active)
                    )
            )
            (results (append
                      (mapcar (lambda (subsingle) (format md4rd--sub-url subsingle)) md4rd-subs-active)
                      (mapcar (lambda (subpair) (car subpair)) md4rd-customurls-active)
                     )
            )
           )
        (dolist (elt (cl-mapcar (lambda (x y) (cons x (cons y nil))) mysubs results) )
          (let (
                (el (car elt))
                (res (cadr elt))
               )
                (expect (md4rd--get--url el) :to-equal res)
          )
        )
      )
  )
)
