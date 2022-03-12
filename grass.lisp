(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity grass-part (lit-sprite rotated-entity listener)
  ((clock :initform 1.0 :accessor clock)
   (velocity :initarg :velocity :initform (vec 0 0) :accessor velocity)
   (face :initarg :face :accessor face)))

(defmethod initialize-instance :after ((part grass-part) &key (face +1))
  (setf (angle part) (* face -1 (random 0.5)))
  (incf (vy (velocity part)) (random 3.0))
  (incf (vx (velocity part)) (* face (random 1.0))))

(defmethod handle ((ev tick) (part grass-part))
  (nv+ (velocity part) (v* (gravity +default-medium+) 0.5 (dt ev)))
  (nv* (velocity part) 0.95)
  (nv+ (location part) (velocity part))
  (decf (angle part) (* (face part) (dt ev)))
  (setf (vw (color-mask part)) (clamp 0.0 (* 2.0 (clock part)) 1.0))
  (when (<= (decf (clock part) (dt ev)) 0.0)
    (leave* part T)))

(define-shader-entity grass-patch (lit-entity sized-entity resizable renderable listener ephemeral creatable)
  ((texture :initform (// 'kandria 'grass) :accessor texture)
   (vertex-buffer :accessor vertex-buffer)
   (vertex-array :accessor vertex-array)
   (patches :initarg :patches :initform 16 :accessor patches :type integer)
   (tile-size :initarg :tile-size :initform (vec 4 16) :accessor tile-size :type vec2)
   (tile-start :initarg :tile-start :initform (vec 0 0) :accessor tile-start :type vec2)
   (tile-count :initarg :tile-count :initform 8 :accessor tile-count :type integer)
   (cut-patches :initform (make-array 0 :element-type 'bit) :accessor cut-patches)))

(defmethod initialize-instance :after ((patch grass-patch) &key)
  (let* ((data (make-array 0 :element-type 'single-float))
         (vbo (make-instance 'vertex-buffer :buffer-data data)))
    (setf (vertex-buffer patch) vbo)
    (setf (vertex-array patch)
          (make-instance 'vertex-array :bindings `((,vbo :size 2 :offset 0 :stride 8)
                                                   (,vbo :size 2 :offset 32 :stride 24 :instancing 1)
                                                   (,vbo :size 2 :offset 40 :stride 24 :instancing 1)
                                                   (,vbo :size 2 :offset 48 :stride 24 :instancing 1))))
    (resize patch (* (patches patch) (vx (tile-size patch))) (vy (tile-size patch)))))

(defmethod layer-index ((patch grass-patch)) (1- +base-layer+))

(defmethod resize ((patch grass-patch) w h)
  (with-slots (tile-size tile-start tile-count) patch
    (let* ((patches (floor w (vx (tile-size patch))))
           (data (make-array (+ (* 4 2) (* patches (+ 2 2 2))) :element-type 'single-float))
           (i 0))
      (setf (cut-patches patch) (make-array patches :element-type 'bit :initial-element 0))
      (setf (patches patch) patches)
      (setf (bsize patch) (nv/ (vec (* patches (vx tile-size)) (vy tile-size)) 2))
      (setf (buffer-data (vertex-buffer patch)) data)
      (flet ((seta (&rest values)
               (loop for value in values
                     do (setf (aref data i) value)
                        (incf i))))
        ;; Base quad.
        (let ((xsi (vx tile-size)) (ysi (vy tile-size)))
          (seta 0.0 0.0
                xsi 0.0
                xsi ysi
                0.0 ysi))
        ;; Fill data.
        (loop for j from 0 below patches
              for xoff from (- (vx (bsize patch))) by (vx tile-size)
              do (seta xoff 0.0
                       0.0 0.0
                       (+ (vx tile-start) (* (vx tile-size) (random tile-count))) (vy tile-start)))
        (when (allocated-p (vertex-buffer patch))
          (resize-buffer (vertex-buffer patch) T))))))

(defmethod handle ((ev switch-chunk) (patch grass-patch))
  (fill (cut-patches patch) 0))

(defmethod handle ((ev tick) (patch grass-patch))
  (declare (optimize speed))
  (when (in-view-p (location patch) (bsize patch))
    (let* ((player (unit 'player +world+))
           (hurt (hurtbox player)))
      (when (< 0 (vz hurt))
        (let ((cuts (cut-patches patch))
              (x0 (- (vx (location patch)) (vx (bsize patch)))))
          (loop for i from (max 0 (ceiling (- (- (vx hurt) (vz hurt)) x0) (vx (tile-size patch))))
                below (min (patches patch) (floor (- (+ (vx hurt) (vz hurt)) x0) (vx (tile-size patch))))
                for x = (+ x0 (* i (vx (tile-size patch))))
                do (when (= 0 (sbit cuts i))
                     (setf (sbit cuts i) 1)
                     (enter* (make-instance 'grass-part :texture (texture patch)
                                                        :size (tile-size patch)
                                                        :bsize (v/ (tile-size patch) 2)
                                                        :location (vec x (+ (vy (location patch)) (vy (bsize patch))))
                                                        :layer (1+ +base-layer+)
                                                        :velocity (vcopy (velocity player))
                                                        :face (direction player))
                             (region +world+)))))))
    (let ((shear (/ (float (sin (the double-float (tt ev))) 0f0) 4))
          (data (buffer-data (vertex-buffer patch)))
          (patches (patches patch))
          (cuts (cut-patches patch))
          (deps ()))
      (declare (type (simple-array single-float) data))
      (declare (type simple-bit-vector cuts))
      (declare (type (unsigned-byte 16) patches))
      (scan +world+ patch (lambda (hit)
                            (when (typep (hit-object hit) 'moving)
                              (let ((x (vx (location (hit-object hit)))))
                                (push (* (+ (/ (- x (vx (location patch))) (vx (bsize patch)) 2) 0.5) patches) deps)))
                            T))
      (flet ((closest-dep (i)
               (let ((min (or (first deps) -10)))
                 (dolist (dep (rest deps) min)
                   (when (< (abs (- i dep)) (abs (- i min)))
                     (setf min dep))))))
        (dotimes (i patches)
          (let* ((idx (+ 8 (* i 6) 2))
                 (r (min 1.0 (+ 0.5 (/ (logand 255 (logxor (* 13 i) #x243A)) 256.0))))
                 (depx (closest-dep i))
                 (amount (+ (clamp 0 (- 1 (abs (/ (- depx i 1) 4.0))) 1)
                            (/ r 3)
                            shear))
                 (actual-x (* 16 amount))
                 (actual-y (* (/ (vy (size patch)) -2.0) amount)))
            (setf (aref data (+ 0 idx)) actual-x)
            (setf (aref data (+ 1 idx)) (if (= 1 (sbit cuts i)) -32.0 actual-y)))))
      (update-buffer-data (vertex-buffer patch) data))))

(defmethod render ((patch grass-patch) (program shader-program))
  (setf (uniform program "model_matrix") (model-matrix))
  (setf (uniform program "view_matrix") (view-matrix))
  (setf (uniform program "projection_matrix") (projection-matrix))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2D (gl-name (texture patch)))
  (gl:bind-vertex-array (gl-name (vertex-array patch)))
  (%gl:draw-arrays-instanced :triangle-fan 0 4 (patches patch)))

(defmethod stage ((patch grass-patch) (area staging-area))
  (stage (texture patch) area)
  (stage (vertex-array patch) area))

(define-class-shader (grass-patch :vertex-shader)
  "layout (location = 0) in vec2 position;
layout (location = 1) in vec2 offset;
layout (location = 2) in vec2 shear;
layout (location = 3) in vec2 tex_offset;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

out vec2 tex_coord;
out vec2 world_pos;

void main(){
  int shear_mult = gl_VertexID / 2;
  vec2 pos = position+offset+(shear*shear_mult);
  vec4 wpos = model_matrix * vec4(pos, 0.0f, 1.0f);
  gl_Position = projection_matrix * view_matrix * wpos;
  tex_coord = position + tex_offset;
  world_pos = wpos.xy;
}")

(define-class-shader (grass-patch :fragment-shader)
  "in vec2 tex_coord;
in vec2 world_pos;

uniform sampler2D tex_image;

out vec4 color;

void main(){
  color = texelFetch(tex_image, ivec2(tex_coord), 0);
  color = apply_lighting_flat(color, vec2(0, -5), 0.0, world_pos);
}")
