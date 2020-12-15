(in-package #:ASDF/USER)
(defun convert-palette (file palette)
  (let* ((palette (pngload:data (pngload:load-file palette)))
         (input (pngload:load-file file :flatten T))
         (data (pngload:data input)))
    (flet ((find-color (r g b)
             (loop for x from 0 below (array-dimension palette 1)
                   do (when (and (= r (aref palette 0 x 0))
                                 (= g (aref palette 0 x 1))
                                 (= b (aref palette 0 x 2)))
                        (return x)))))
      (loop for i from 0 below (length data) by 4
            for index = (when (< 0 (aref data (+ i 3)))
                          (find-color (aref data (+ i 0))
                                      (aref data (+ i 1))
                                      (aref data (+ i 2))))
            do (when index
                 (setf (aref data (+ i 0)) 255)
                 (setf (aref data (+ i 1)) index)
                 (setf (aref data (+ i 2)) 255))))
    (zpng:write-png (make-instance 'zpng:png :color-type :truecolor-alpha
                                             :width (pngload:width input)
                                             :height (pngload:height input)
                                             :image-data data)
                    file :if-exists :supersede)))

(defun re-encode-json (file)
  (let* ((data (jsown:parse (alexandria:read-file-into-string file))))
    (let ((*print-pretty* nil))
      (with-open-file (output file :direction :output
                                   :if-exists :supersede)
        (jsown::write-object-to-stream data output)))))
