(in-package #:org.shirakumo.fraf.kandria)

#++
(defun test-damage-scales (&key (base-damage 50) (skip 1))
  (flet ((p (enemy-level base-damage level health)
           (let ((attack (* base-damage 5 (expt 1.06 enemy-level))))
             (format T " | ~[  ~;->~;X>~] ~2d ~2d ~8d ~10d ~8d"
                     (cond ((= enemy-level level) 1)
                           ((<= health attack) 2)
                           (T 0))
                     level enemy-level
                     (truncate health)
                     (truncate attack)
                     (truncate (max 0 (* 100 (/ (- health attack) health))))))))
    (let ((levels '(0 10 30 70 99)))
      (dolist (level levels (terpri))
        (format T " |  PLVL ELVL  PHLTH        ATK     REM%"))
      (loop for level from 0 to 99 by skip
            for health = (maximum-health-for-level 1000 level)
            do (dolist (enemy-level levels (terpri))
                 (p enemy-level base-damage level health))))))

(define-global +max-stun+ 1f0)
(define-global +hard-hit+ 0.1)

(defun maximum-health-for-level (base-health level)
  (* base-health (expt 1.05 level)))

(defun exp-needed-for-level (level)
  (floor (+ (* 658 level) (* 500 (cos (* level 0.8))))))

(define-shader-entity animatable (movable lit-animated-sprite)
  ((maximum-health :initarg :maximum-health :accessor maximum-health)
   (health :initarg :health :accessor health)
   (stun-time :initform 0f0 :accessor stun-time)
   (idle-time :initform 0f0 :accessor idle-time)
   (cooldown-time :initform 0f0 :accessor cooldown-time)
   (iframes :initform 0 :accessor iframes)
   (iframe-idx :initform 0 :accessor iframe-idx)
   (knockback :initform (vec 0 0) :accessor knockback)
   (invincible :initform NIL :initarg :invincible :accessor invincible-p)
   (level :initform 1 :initarg :level :accessor level :type integer)
   (experience :initform 0 :initarg :experience :accessor experience)
   (active-effects :initform () :initarg :active-effects :accessor active-effects)
   (active-effects-sprite :initform (make-instance 'lit-animated-sprite :sprite-data (asset 'kandria 'active-item)) :accessor active-effects-sprite)
   (damage-output-scale :initform 1.0 :accessor damage-output-scale)
   (damage-input-scale :initform 1.0 :accessor damage-input-scale)))

(defmethod initialize-instance :after ((animatable animatable) &key)
  (setf (idle-time animatable) (minimum-idle-time animatable))
  (unless (slot-boundp animatable 'maximum-health)
    (setf (slot-value animatable 'maximum-health)
          (maximum-health-for-level (base-health animatable) (level animatable))))
  (unless (slot-boundp animatable 'health)
    (setf (slot-value animatable 'health) (maximum-health animatable))))

(defgeneric idleable-p (animatable))
(defgeneric minimum-idle-time (animatable))
(defgeneric kill (animatable))
(defgeneric die (animatable))
(defgeneric interrupt (animatable))
(defgeneric hit (animatable location))
(defgeneric hurt (animatable attacker))
(defgeneric stun (animatable stun))
(defgeneric start-animation (name animatable))
(defgeneric endangering (animatable))
(defgeneric base-health (animatable))
(defgeneric damage-output (animatable))
(defgeneric experience-reward (animatable))
(defgeneric award-experience (animatable exp))

(defmethod stage :after ((animatable animatable) (area staging-area))
  (stage (active-effects-sprite animatable) area))

(defmethod experience-reward ((animatable animatable))
  (* (level animatable) 10))

(defmethod health-percentage ((animatable animatable))
  (truncate (* 100 (health animatable)) (maximum-health animatable)))

(defmethod (setf level) :around (level (animatable animatable))
  (let ((health-percentage (/ (health animatable) (maximum-health animatable)))
        (level (clamp 1 level 99)))
    (call-next-method level animatable)
    (setf (maximum-health animatable) (maximum-health-for-level (base-health animatable) level))
    (setf (slot-value animatable 'health) (* health-percentage (maximum-health animatable)))))

(defmethod level-up ((animatable animatable))
  (incf (level animatable)))

(defmethod award-experience ((animatable animatable) exp)
  (trigger (make-instance 'text-effect) animatable
           :text (format NIL "+~d XP" exp)
           :location (vec (+ (vx (location animatable)))
                          (+ (vy (location animatable)) 8 (vy (bsize animatable)))))
  (incf (experience animatable) exp))

(defmethod (setf experience) :around ((experience integer) (animatable animatable))
  (loop for needed = (exp-needed-for-level (level animatable))
        while (<= needed experience)
        do (level-up animatable)
           (decf experience needed))
  (call-next-method experience animatable))

(defmethod damage-output ((animatable animatable))
  (let ((base (damage (frame animatable))))
    (ceiling
     (* (max base (* base 5 (expt 1.06 (level animatable))))
        (damage-output-scale animatable)))))

(alloy:make-observable '(setf health) '(value alloy:observable))

(defmethod minimum-idle-time ((animatable animatable)) 10)

(defmethod (setf health) :around (health (animatable animatable))
  (call-next-method (clamp 0 health (maximum-health animatable)) animatable))

(defmethod enter :after ((entity animatable) (magma magma))
  (kill entity))

(defmethod hurtbox ((animatable animatable))
  (let* ((location (location animatable))
         (direction (direction animatable))
         (frame (frame animatable))
         (hurtbox (hurtbox frame)))
    (vec4 (+ (vx location) (* (vx hurtbox) direction))
          (+ (vy location) (vy hurtbox))
          (vz hurtbox)
          (vw hurtbox))))

(defmethod attacking-p ((animatable animatable))
  (let ((idx (frame-idx animatable))
        (end (end (animation animatable)))
        (frames (frames animatable))
        (precognition-frames 3))
    (loop for i from idx below (min end (+ precognition-frames idx))
          thereis (< 0 (vw (hurtbox (svref frames i)))))))

(defmethod endangering ((animatable animatable))
  (let ((loc (location animatable)))
    (bvh:do-fitting (entity (bvh (region +world+)) (tvec (- (vx loc) 128)
                                                         (- (vy loc) 128)
                                                         (+ (vx loc) 128)
                                                         (+ (vy loc) 128)))
      (when (and (typep entity 'animatable)
                 (not (eql animatable entity))
                 (attacking-p entity)
                 (or (< (vdistance (location entity) (location animatable)) +tile-size+)
                     (let ((hurtbox (hurtbox entity)))
                       (aabb (location animatable) (tv- (velocity animatable) (velocity entity))
                             (vxy hurtbox) (nv+ (vwz hurtbox) (bsize animatable) 16)))))
        (return entity)))))

(defmethod hurt :around ((animatable animatable) (damage integer))
  (when (and (<= 0 (health animatable))
             (not (invincible-p (frame animatable))))
    (prog1 (call-next-method)
      (when (<= (health animatable) 0)
        (kill animatable)))))

(defmethod hurt ((animatable animatable) (attacker animatable))
  (hurt animatable (damage-output attacker)))

(defmethod hurt :after ((animatable animatable) (attacker animatable))
  (when (<= (health animatable) 0)
    (award-experience attacker (experience-reward animatable))))

(defmethod hurt ((animatable animatable) (damage integer))
  (let* ((damage (* (damage-input-scale animatable) damage))
         (hard-hit-p (<= (* +hard-hit+ (maximum-health animatable)) damage)))
    (cond ((invincible-p animatable)
           (setf damage 0))
          (hard-hit-p
           (setf (pause-timer +world+) 0.08)
           (when (interrupt animatable)
             (setf (animation animatable) 'hard-hit))))
    (trigger (make-instance 'text-effect) animatable
             :text (princ-to-string (truncate damage))
             :location (vec (+ (vx (location animatable)))
                            (+ (vy (location animatable)) 8 (vy (bsize animatable)))))
    (decf (health animatable) damage)))

(defmethod kill :around ((animatable animatable))
  (unless (or (eql :dying (state animatable))
              (eql :respawning (state animatable)))
    (call-next-method)))

(defmethod kill ((animatable animatable))
  (setf (state animatable) :dying)
  (setf (animation animatable) 'die))

(defmethod die ((animatable animatable))
  (when (slot-boundp animatable 'container)
    (leave* animatable T)))

(defmethod switch-animation :before ((animatable animatable) next)
  ;; Remove selves when death animation completes
  (when (or (eql (name (animation animatable)) 'die)
            (eql (name (animation animatable)) 'magma-death))
    (die animatable))
  (when (and (eql next 'stand)
             (find (state animatable) '(:dying :animated)))
    (setf (state animatable) :normal)))

(defmethod (setf frame-idx) :before (idx (animatable animatable))
  (let ((previous-idx (frame-idx animatable)))
    (when (/= idx previous-idx)
      (let ((effect (effect (svref (frames animatable) idx))))
        (when effect
          (trigger effect animatable))))))

(defmethod hit ((animatable animatable) location)
  (setf (vy (velocity animatable)) (max 0.0 (vy (velocity animatable))))
  (trigger 'hit animatable :location location))

(defmethod interrupt ((animatable animatable))
  (when (interruptable-p (frame animatable))
    (unless (eql :stunned (state animatable))
      (setf (animation animatable) 'light-hit)
      (setf (path animatable) ())
      (setf (state animatable) :animated))))

(defmethod stun ((animatable animatable) stun)
  (when (and (< 0 stun)
             (not (eql :dying (state animatable)))
             (interruptable-p (frame animatable)))
    (setf (stun-time animatable) (min +max-stun+ (+ (stun-time animatable) stun)))
    (setf (path animatable) ())
    (setf (state animatable) :stunned)))

(defmethod start-animation (name (animatable animatable))
  (when (or (not (eql :animating (state animatable)))
            (cancelable-p (frame animatable)))
    (setf (animation animatable) name)
    (setf (state animatable) :animated)))

(defmethod handle-animation-states ((animatable animatable) ev)
  (let ((vel (velocity animatable))
        (frame (frame animatable))
        (dt (dt ev))
        (g (gravity (medium animatable))))
    (incf (vx vel) (* (vx g) (dt ev)))
    (incf (vy vel) (* (vy g) (dt ev)))
    (setf (cooldown-time animatable)
          (max (cooldown-time animatable) (cooldown (animation animatable))))
    (case (state animatable)
      (:animated
       (setf (stun-time animatable) 0f0)
       (when (/= 0 (vz (hurtbox frame)) (vw (hurtbox frame)))
         (let* ((hurtbox (hurtbox animatable))
                (region (vec (- (vx hurtbox) (vz hurtbox) 10)
                             (- (vy hurtbox) (vw hurtbox) 10)
                             (+ (vx hurtbox) (vz hurtbox) 10)
                             (+ (vy hurtbox) (vw hurtbox) 10))))
           (declare (dynamic-extent region))
           (bvh:do-fitting (entity (bvh (region +world+)) region)
             (typecase entity
               (animatable
                (when (and (not (eq animatable entity))
                           (contained-p hurtbox entity))
                  (when (and (iframe-clearing-p frame)
                             (/= (frame-idx animatable) (iframe-idx entity)))
                    (setf (iframes entity) 0))
                  (when (<= (iframes entity) 0)
                    (hit entity (intersection-point (vxy hurtbox) (vzw hurtbox) (location entity) (bsize entity)))
                    (let ((interruptable (interruptable-p (frame entity))))
                      (when (hurt entity animatable)
                        (when (eql 'hard-hit (name (animation entity)))
                          (setf (direction entity) (float-sign (- (vx (location animatable))
                                                                  (vx (location entity))))))
                        (when interruptable
                          (cond ((<= (stun-time entity) 0)
                                 (vsetf (velocity entity)
                                        (* (direction animatable) (random* (vx (knockback frame)) 1.0))
                                        (vy (knockback frame))))
                                (T
                                 (vsetf (knockback entity)
                                        (* (direction animatable) (random* (vx (knockback frame)) 1.0))
                                        (vy (knockback frame)))))
                          (stun entity (stun-time frame))))))
                  (when (<= (iframes entity) 0)
                    (setf (iframe-idx entity) (frame-idx animatable))
                    (setf (iframes entity) 60))))
               (chest                   ; KLUDGE: generify this...
                (when (contained-p hurtbox entity)
                  (interact entity animatable))))))))
      (:stunned
       (cond ((and (<= (stun-time animatable) 0)
                   #++(svref (collisions animatable) 2))
              (nv+ (velocity animatable) (knockback animatable))
              (vsetf (knockback animatable) 0 0)
              (setf (state animatable) :normal))
             ((< 0 (stun-time animatable))
              (setf (vy vel) (max 0 (vy vel)))
              (decf (stun-time animatable) (dt ev))))
       (when (svref (collisions animatable) 3)
         (setf (vx (velocity animatable)) (max 0.0 (vx (velocity animatable)))))
       (when (svref (collisions animatable) 1)
         (setf (vx (velocity animatable)) (min 0.0 (vx (velocity animatable))))))
      ((:dying :respawning)))
    (nv* vel (multiplier frame))
    (incf (vx vel) (* dt (direction animatable) (vx (acceleration frame))))
    (incf (vy vel) (* dt (vy (acceleration frame))))))

(defmethod idleable-p ((animatable animatable))
  (and (= 0 (vx (velocity animatable)))
       (= 0 (vx (frame-velocity animatable)))
       (svref (collisions animatable) 2)
       (null (path animatable))
       (eql :normal (state animatable))))

(defmethod handle :before ((ev tick) (animatable animatable))
  (setf (damage-input-scale animatable) 1.0)
  (setf (damage-output-scale animatable) 1.0)
  (when (active-effects animatable)
    (setf (active-effects animatable)
          (delete-if (lambda (effect)
                       (apply-effect effect animatable)
                       (<= (decf (clock effect) (dt ev)) 0))
                     (active-effects animatable)))
    (handle ev (active-effects-sprite animatable)))
  (decf (cooldown-time animatable) (dt ev))
  (when (and (< 0 (iframes animatable))
             (< 0 (dt ev)))
    (decf (iframes animatable)))
  (cond ((idleable-p animatable)
         (decf (idle-time animatable) (dt ev))
         (when (<= (idle-time animatable) 0.0)
           (setf (idle-time animatable) (+ (minimum-idle-time animatable) (random 8.0)))
           (start-animation 'idle animatable)))
        ((not (eql 'idle (name (animation animatable))))
         (setf (idle-time animatable) (minimum-idle-time animatable)))))

(defmethod collide :before ((animatable animatable) (platform falling-platform) hit)
  (when (<= 0 (vy (hit-normal hit)))
    (case (state platform)
      (:normal
       (setf (state platform) :falling)))))

(defmethod apply-transforms progn ((animatable animatable))
  (when (eql :stunned (state animatable))
    (let* ((frame-id (logand #xFF (sxhash (mod (floor (* (clock +world+) 100)) 100))))
           (r (* frame-id 0.01))
           (p (* frame-id (/ (* 2 PI) #xFF))))
      (translate-by (* r (cos p))
                    (* r (sin p))
                    0.0)))
  (let ((offset (offset (frame animatable))))
    (translate-by (vx offset) (vy offset) 0)))

(defmethod render :after ((animatable animatable) (program shader-program))
  (when (active-effects animatable)
    (setf (location (active-effects-sprite animatable)) (location animatable))
    (render (active-effects-sprite animatable) program)))
