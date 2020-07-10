(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity enemy (animatable)
  ((bsize :initform (vec 8.0 8.0))
   (cooldown :initform 0.0 :accessor cooldown))
  (:default-initargs
   :sprite-data (asset 'leaf 'wolf)))

(defmethod capable-p ((enemy enemy) (edge crawl-edge)) T)
(defmethod capable-p ((enemy enemy) (edge jump-edge)) T)

(defmethod handle :before ((ev tick) (enemy enemy))
  (when (path enemy)
    (handle-ai-states enemy ev)
    (return-from handle))
  (let ((collisions (collisions enemy))
        (vel (velocity enemy))
        (dt (* 100 (dt ev))))
    (setf (vx vel) (* (vx vel) (damp* (vy +vmove+) dt)))
    (nv+ vel (v* +vgrav+ dt))
    (cond ((svref collisions 2)
           (when (<= -0.1 (vx vel) 0.1)
             (setf (vx vel) 0)))
          (T
           (when (<= 2 (vx vel))
             (setf (vx vel) (* (vx vel) (damp* 0.90 dt))))))
    (when (svref collisions 0) (setf (vy vel) (min 0 (vy vel))))
    (when (svref collisions 1) (setf (vx vel) (min 0 (vx vel))))
    (when (svref collisions 3) (setf (vx vel) (max 0 (vx vel))))
    (case (state enemy)
      ((:dying :animated :stunned)
       (handle-animation-states enemy ev))
      (T
       (handle-ai-states enemy ev)))
    (nvclamp (v- +vlim+) vel +vlim+)
    (nv+ (frame-velocity enemy) vel)))

(defmethod handle :after ((ev tick) (enemy enemy))
  ;; Animations
  (let ((vel (velocity enemy))
        (collisions (collisions enemy)))
    (case (state enemy)
      ((:dying :animated :stunned))
      (T
       (cond ((< 0 (vx vel))
              (setf (direction enemy) +1))
             ((< (vx vel) 0)
              (setf (direction enemy) -1)))
       (cond ((< 0 (vy vel))
              (setf (animation enemy) 'jump))
             ((null (svref collisions 2))
              (setf (animation enemy) 'fall))
             ((<= 0.75 (abs (vx vel)))
              (setf (animation enemy) 'run))
             ((< 0 (abs (vx vel)))
              (setf (animation enemy) 'walk))
             (T
              (setf (animation enemy) 'stand)))))))

(define-shader-entity wolf (enemy)
  ())

(defmethod movement-speed ((enemy wolf))
  (case (state enemy)
    (:crawling 0.4)
    (:normal 0.5)
    (T 2.0)))

(defmethod handle-ai-states ((enemy wolf) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (distance (vlength (v- ploc eloc)))
         (col (collisions enemy))
         (vel (velocity enemy)))
    (ecase (state enemy)
      ((:normal :crawling)
       (cond ;; ((< distance 400)
             ;;  (setf (state enemy) :approach))
         ((and (null (path enemy)) (<= (cooldown enemy) 0))
          (if (ignore-errors (move-to (vec (+ (vx (location enemy)) (- (random 200) 50)) (+ (vy (location enemy)) 64)) enemy))
              (setf (cooldown enemy) (+ 0.5 (expt (random 1.5) 2)))
              (setf (cooldown enemy) 0.1)))
         ((null (path enemy))
          (decf (cooldown enemy) (dt ev)))))
      (:approach (setf (state enemy) :normal))
      ;; (:approach
      ;;  ;; FIXME: This should be reached even when there is a path being executed right now.
      ;;  (cond ((< distance 200)
      ;;         (setf (path enemy) ())
      ;;         (setf (state enemy) :attack))
      ;;        ((null (path enemy))
      ;;         (ignore-errors (move-to (location player) enemy)))))
      ;; (:evade
      ;;  (if (< 100 distance)
      ;;      (setf (state enemy) :attack)
      ;;      (let ((dir (signum (- (vx eloc) (vx ploc)))))
      ;;        (when (and (svref col 2) (svref col (if (< 0 dir) 1 3)))
      ;;          (setf (vy vel) 3.2))
      ;;        (setf (vx vel) (* dir 2.0)))))
      ;; (:attack
      ;;  (cond ((< 500 distance)
      ;;         (setf (state enemy) :normal))
      ;;        ((< distance 80)
      ;;         (setf (state enemy) :evade))
      ;;        (T
      ;;         (setf (direction enemy) (signum (- (vx (location player)) (vx (location enemy)))))
      ;;         (cond ((svref col (if (< 0 (direction enemy)) 1 3))
      ;;                (setf (vy vel) 2.0)
      ;;                (setf (vx vel) (* (direction enemy) 2.0)))
      ;;               ((svref col 2)
      ;;                (setf (vy vel) 0.0)
      ;;                ;; Check that tackle would even be possible to hit (no obstacles)
      ;;                (start-animation 'tackle enemy))))))
      )))
