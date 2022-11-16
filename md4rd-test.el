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

(describe "A suite"
  (it "contains a spec with an expectation"
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
