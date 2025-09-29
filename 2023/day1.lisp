(defconstant +named-digits+ '(("one"   . 1)
                              ("two"   . 2)
                              ("three" . 3)
                              ("four"  . 4)
                              ("five"  . 5)
                              ("six"   . 6)
                              ("seven" . 7)
                              ("eight" . 8)
                              ("nine"  . 9)))

(defun string-starts-with (s1 s2 &key (start 0))
  (let ((end (+ start (length s2)))) 
    (when (<= end (length s1))
      (string= s1 s2 :start1 start :end1 end))))

(defun convert-to-digit (s)
  (unless (zerop (length s))  ; Look for digits
    (let* ((ch (aref s 0)) (d (digit-char-p ch)))
      (when d
        (return-from convert-to-digit
                     (list d (subseq s 1)))))

    (loop for (nd . d) in +named-digits+ ; Look for named-digits 
          when (string-starts-with s nd)
          do (return-from convert-to-digit 
                          (list d (subseq s 
                                          (1- (length nd))))))) ; Handle cases like 'oneight'  

  (list nil (subseq s 1)))  ; Advance by 1-char 

(defun process-line (line)
  (let ((n2 nil) (n1 nil)) 
    (loop while (> (length line) 0)
          for res = (convert-to-digit line)
          do (setq line (second res)) ; Update remaining string   
          when (first res)            ; Check digit
          do (if n2 
                 (setf n1 (first res)) 
                 (setf n2 (first res) n1 (first res))))
    (if (and n2 n1) 
        (+ n1 (* n2 10)) 
        0)))

(defparameter *total*  0)

(with-open-file (stream "./day1.txt")
  (loop for line = (read-line stream nil)
        until (null line)
        do (setf *total* (+ *total* (process-line line)))))

(format t "Total is: ~a~%" *total*)
