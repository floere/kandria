(in-package #:org.shirakumo.fraf.kandria)

(define-global +max-stun+ 1f0)
(define-global +hard-hit+ 20)

(define-shader-entity animatable (movable lit-animated-sprite)
  ((health :initarg :health :accessor health)
   (stun-time :initform 0f0 :accessor stun-time)
   (idle-time :initform 0f0 :accessor idle-time)
   (cooldown-time :initform 0f0 :accessor cooldown-time)
   (iframes :initform 0 :accessor iframes)
   (iframe-idx :initform 0 :accessor iframe-idx)
   (knockback :initform (vec 0 0) :accessor knockback)
   (invincible :initform NIL :initarg :invincible :accessor invincible-p)))

(defmethod initialize-instance :after ((animatable animatable) &key)
  (setf (idle-time animatable) (minimum-idle-time animatable))
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
(defgeneric maximum-health (animatable))
(defgeneric damage-output (animatable))

(defmethod health-percentage ((animatable animatable))
  (truncate (* 100 (health animatable)) (maximum-health animatable)))

(defmethod damage-output ((animatable animatable))
  (damage (frame animatable)))

(alloy:make-observable '(setf health) '(value alloy:observable))

(defmethod minimum-idle-time ((animatable animatable)) 10)

(defmethod (setf health) :around (health (animatable animatable))
  (call-next-method (clamp 0 health (maximum-health animatable)) animatable))

(defmethod apply-transforms progn ((animatable animatable))
  (let ((frame (frame animatable)))
    (translate-by (vx (offset frame))
                  (vy (offset frame))
                  0)))

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
  ;; KLUDGE: this sucks and is slow. Dunno how to rewrite it with BVH, but it has to be done.
  (for:for ((entity over (region +world+)))
    (when (and (typep entity 'animatable)
               (not (eql animatable entity))
               (attacking-p entity)
               (or (< (vdistance (location entity) (location animatable)) +tile-size+)
                   (let ((hurtbox (hurtbox entity)))
                     (aabb (location animatable) (tv- (velocity animatable) (velocity entity))
                           (vxy hurtbox) (nv+ (vwz hurtbox) (bsize animatable))))))
      (return entity))))

(defmethod hurt :around ((animatable animatable) (damage integer))
  (prog1 (when (and (< 0 (health animatable))
                    (not (invincible-p (frame animatable))))
           (call-next-method))
    (when (<= (health animatable) 0)
      (kill animatable))))

(defmethod hurt ((animatable animatable) (attacker animatable))
  (hurt animatable (damage-output attacker)))

(defmethod hurt ((animatable animatable) (damage integer))
  (cond ((invincible-p animatable)
         (setf damage 0))
        ((interrupt animatable)
         (when (<= +hard-hit+ damage)
           (setf (animation animatable) 'hard-hit))))
  (trigger (make-instance 'text-effect) animatable
           :text (princ-to-string damage)
           :location (vec (+ (vx (location animatable)))
                          (+ (vy (location animatable)) 8 (vy (bsize animatable)))))
  (setf (pause-timer +world+) 0.08)
  (decf (health animatable) damage))

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
  (when (eql (name (animation animatable)) 'die)
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
  (setf (pause-timer +world+) 0.15))

(defmethod interrupt ((animatable animatable))
  (when (interruptable-p (frame animatable))
    (unless (eql :stunned (state animatable))
      (setf (animation animatable) 'light-hit)
      (setf (state animatable) :animated))))

(defmethod stun ((animatable animatable) stun)
  (when (and (< 0 stun)
             (not (eql :dying (state animatable)))
             (interruptable-p (frame animatable)))
    (setf (stun-time animatable) (min +max-stun+ (+ (stun-time animatable) stun)))
    (setf (state animatable) :stunned)))

(defmethod start-animation (name (animatable animatable))
  (when (or (not (eql :animating (state animatable)))
            (cancelable-p (frame animatable)))
    (setf (animation animatable) name)
    (setf (state animatable) :animated)))

(defmethod handle-animation-states ((animatable animatable) ev)
  (let ((vel (velocity animatable))
        (frame (frame animatable))
        (dt (dt ev)))
    (nv+ vel (v* (gravity (medium animatable)) dt))
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
             (when (and (not (eq animatable entity))
                        (typep entity 'animatable)
                        (contained-p hurtbox entity))
               (when (and (iframe-clearing-p frame)
                          (/= (frame-idx animatable) (iframe-idx entity)))
                 (setf (iframes entity) 0))
               (when (<= (iframes entity) 0)
                 (hit entity (intersection-point (vxy hurtbox) (vzw hurtbox) (location entity) (bsize entity)))
                 (setf (direction entity) (float-sign (- (vx (location animatable))
                                                         (vx (location entity))$)))
                 (when (hurt entity animatable)
                   (when (interruptable-p (frame entity))
                     (cond ((<= (stun-time entity) 0)
                            (vsetf (velocity entity)
                                   (* (direction animatable) (vx (knockback frame)))
                                   (vy (knockback frame))))
                           (T
                            (vsetf (knockback entity)
                                   (* (direction animatable) (vx (knockback frame)))
                                   (vy (knockback frame)))))
                     (stun entity (stun-time frame)))))
               (when (<= (iframes entity) 0)
                 (setf (iframe-idx entity) (frame-idx animatable))
                 (setf (iframes entity) 60)))))))
      (:stunned
       (decf (stun-time animatable) (dt ev))
       (setf (vy vel) (max 0 (vy vel)))
       (when (<= (stun-time animatable) 0)
         (nv+ (velocity animatable) (knockback animatable))
         (vsetf (knockback animatable) 0 0)
         (setf (state animatable) :normal)))
      ((:dying :respawning)))
    (nv* vel (multiplier frame))
    (incf (vx vel) (* dt (direction animatable) (vx (acceleration frame))))
    (incf (vy vel) (* dt (vy (acceleration frame))))))

(defmethod idleable-p ((animatable animatable))
  (and (= 0 (vx (velocity animatable)))
       (svref (collisions animatable) 2)
       (null (path animatable))
       (eql :normal (state animatable))))

(defmethod handle :before ((ev tick) (animatable animatable))
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
  (when (< 0 (vy (hit-normal hit)))
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
                    0.0))))
