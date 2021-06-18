(in-package #:org.shirakumo.fraf.kandria)

(define-global +tile-history+
    (make-array 16 :initial-element '(0 0 1 1)))

(defclass tile-button (alloy:button)
  ((tileset :initarg :tileset :accessor tileset)))

(presentations:define-realization (ui tile-button)
  ((:icon simple:icon)
   (alloy:margins)
   (tileset alloy:renderable)))

(presentations:define-update (ui tile-button)
  (:icon
   :size (alloy:px-size (/ (width (tileset alloy:renderable)) +tile-size+ (third alloy:value))
                        (/ (height (tileset alloy:renderable)) +tile-size+ (fourth alloy:value)))
   :shift (alloy:px-point (* (first alloy:value) (/ +tile-size+ (width (tileset alloy:renderable))))
                          (* (second alloy:value) (/ +tile-size+ (height (tileset alloy:renderable)))))))

(defmethod simple:icon ((renderer ui) bounds (image texture) &rest initargs)
  (apply #'make-instance 'simple:icon :image image initargs))

(defclass tile-info (alloy:label)
  ())

(defmethod alloy:text ((info tile-info))
  (format NIL "~3d / ~3d"
          (floor (first (alloy:value info)))
          (floor (second (alloy:value info)))))

(defclass tile-history (alloy:structure)
  ())

(defmethod initialize-instance :after ((structure tile-history) &key widget)
  (let* ((tileset (albedo (entity widget)))
         (layout (make-instance 'alloy:grid-layout :cell-margins (alloy:margins 1)
                                                   :col-sizes (map 'list (constantly 32) +tile-history+)
                                                   :row-sizes '(32)))
         (focus (make-instance 'alloy:focus-list)))
    (dotimes (i (length +tile-history+))
      (let ((element (alloy:represent (aref +tile-history+ i) 'tile-button
                                      :tileset tileset :layout-parent layout :focus-parent focus
                                      :ideal-bounds (alloy:size 64 64))))
        (alloy:on alloy:activate (element)
          (setf (tile-to-place widget) (alloy:value element)))))
    (alloy:observe 'tile widget (lambda (value object)
                                  (unless (equal value (aref +tile-history+ 0))
                                    (loop for i downfrom (1- (length +tile-history+)) above 0
                                          do (setf (aref +tile-history+ i) (aref +tile-history+ (1- i))))
                                    (setf (aref +tile-history+ 0) value)
                                    (alloy:do-elements (element layout)
                                      (alloy:refresh (alloy:data element))))))
    (alloy:finish-structure structure layout focus)))

(defclass tile-picker (alloy:structure)
  ())

(defmethod initialize-instance :after ((structure tile-picker) &key widget)
  (let* ((tileset (albedo (entity widget)))
         (layout (make-instance 'alloy:grid-layout :cell-margins (alloy:margins 1)
                                                   :col-sizes (loop repeat (/ (width tileset) +tile-size+) collect 18)
                                                   :row-sizes (loop repeat (/ (height tileset) +tile-size+) collect 18)))
         (focus (make-instance 'alloy:focus-list))
         (scroll (make-instance 'alloy:scroll-view :scroll T :layout layout :focus focus)))
    (dotimes (y (/ (height tileset) +tile-size+))
      (dotimes (x (/ (width tileset) +tile-size+))
        (let* ((tile (list x (- (/ (height tileset) +tile-size+) y 1) 1 1))
               (element (make-instance 'tile-button :data (make-instance 'alloy:value-data :value tile)
                                                    :tileset tileset :layout-parent layout :focus-parent focus)))
          (alloy:on alloy:activate (element)
            (if (retained :shift)
                (let ((xd (- (first tile) (first (tile-to-place widget))))
                      (yd (- (second tile) (second (tile-to-place widget)))))
                  (setf (place-width widget) (1+ (floor xd)))
                  (setf (place-height widget) (1+ (floor yd)))
                  (setf (tile-to-place widget) (list (first (tile-to-place widget))
                                                     (second (tile-to-place widget))
                                                     (1+ (floor xd))
                                                     (1+ (floor yd)))))
                (progn
                  (setf (place-width widget) 1)
                  (setf (place-height widget) 1)
                  (setf (tile-to-place widget) tile)))))))
    (alloy:finish-structure structure scroll scroll)))

(alloy:define-widget chunk-widget (sidebar)
  ((layer :initform +base-layer+ :accessor layer :representation (alloy:ranged-slider :range '(0 . 4) :grid 1))
   (tile :initform (list 1 0 1 1) :accessor tile-to-place)
   (tile-set :accessor tile-set)
   (place-width :initform 1 :accessor place-width :representation (alloy:ranged-wheel :grid 1 :range '(1)))
   (place-height :initform 1 :accessor place-height :representation (alloy:ranged-wheel :grid 1 :range '(1)))))

(defmethod initialize-instance :before ((widget chunk-widget) &key editor)
  (setf (tile-set widget) (caar (tile-types (tile-data (entity editor))))))

(defmethod initialize-instance :after ((widget chunk-widget) &key)
  (alloy:on alloy:value (value (alloy:representation 'layer widget))
    (setf (alloy:value (slot-value widget 'show-solids)) NIL)))

(defmethod (setf tile-to-place) :around ((tile vec2) (widget chunk-widget))
  (let* ((w (/ (width (albedo (entity widget))) +tile-size+))
         (h (/ (height (albedo (entity widget))) +tile-size+))
         (x (mod (vx tile) w))
         (y (mod (+ (vy tile) (floor (vx tile) w)) h)))
    (call-next-method (list x y (place-width widget) (place-height widget)) widget)))

(defmethod (setf tile-to-place) :around ((tile cons) (widget chunk-widget))
  (destructuring-bind (x y &optional (w 1) (h 1)) tile
    (call-next-method (list x y w h) widget)))

(defmethod (setf tile-to-place) :after ((tile cons) (widget chunk-widget))
  (setf (alloy:value (slot-value widget 'show-solids)) (= 0 (second tile))))

(alloy:define-subcomponent (chunk-widget show-solids) ((show-solids (entity chunk-widget)) alloy:switch))
(alloy:define-subcomponent (chunk-widget tile-set-list) ((slot-value chunk-widget 'tile-set) alloy:combo-set :value-set (mapcar #'first (tile-types (tile-data (entity chunk-widget))))))
(alloy:define-subobject (chunk-widget tile-history) ('tile-history :widget chunk-widget))
(alloy:define-subobject (chunk-widget tiles) ('tile-picker :widget chunk-widget))
(alloy:define-subcomponent (chunk-widget albedo) ((slot-value chunk-widget 'tile) tile-button :tileset (albedo (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget absorption) ((slot-value chunk-widget 'tile) tile-button :tileset (absorption (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget normal) ((slot-value chunk-widget 'tile) tile-button :tileset (normal (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget tile-info) ((slot-value chunk-widget 'tile) tile-info))
(alloy::define-subbutton (chunk-widget clear) ()
  (alloy:with-confirmation ("Are you sure you want to clear the chunk?" :ui (unit 'ui-pass T))
    (clear (entity chunk-widget))))
(alloy::define-subbutton (chunk-widget compute) ()
  (if (retained :control)
      (recompute (entity chunk-widget))
      (for:for ((entity over (region +world+)))
        (when (typep entity 'chunk)
          (recompute entity))))
  (setf (chunk-graph (region +world+)) (make-chunk-graph (region +world+)))
  (when (typep (tool (editor chunk-widget)) 'move-to)
    (setf (tool (editor chunk-widget)) (tool (editor chunk-widget)))))

(alloy:define-subcontainer (chunk-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(30 30 34 T 30 60))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T 30)
    :row-sizes '(30)
    layer show-solids))
  tile-set-list
  tile-history
  tiles
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T)
    :row-sizes '(30)
    place-width place-height))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(64 64 64 T)
    :row-sizes '(64)
    albedo absorption normal tile-info))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T)
    :row-sizes '(30)
    clear compute)))

(alloy:define-subcontainer (chunk-widget focus)
    (alloy:focus-list)
  layer show-solids tile-set-list tile-history tiles place-width place-height clear compute)

(defmethod (setf entity) :after ((chunk chunk) (editor editor))
  (setf (sidebar editor) (make-instance 'chunk-widget :editor editor :side :east)))

(defmethod applicable-tools append ((_ chunk))
  '(paint rectangle line selection move-to))

(defmethod default-tool ((_ chunk))
  'freeform)
