(in-package #:org.shirakumo.fraf.leaf)

(define-subject moving (game-entity)
  ((collisions :initform (make-array 4) :reader collisions)))

(defmethod scan (entity target))

(defmethod tick ((moving moving) ev)
  (let* ((surface (surface moving))
         (loc (location moving))
         (vel (velocity moving))
         (size (bsize moving)))
    ;; Scan for hits
    (fill (collisions moving) NIL)
    (loop repeat 10 while (scan surface moving))
    ;; Remaining velocity (if any) can be added safely.
    (nv+ loc vel)
    ;; Point test for adjacent walls
    (let ((l (scan surface (vec (- (vx loc) (vx size) 1) (vy loc))))
          (r (scan surface (vec (+ (vx loc) (vx size) 1) (vy loc))))
          (b (scan surface (vec (vx loc) (- (vy loc) (vy size) 1)))))
      (when l (setf (aref (collisions moving) 3) l))
      (when r (setf (aref (collisions moving) 1) r))
      (when b (setf (aref (collisions moving) 2) b)))
    ;; Point test for interactables. Pretty stupid.
    (for:for ((entity over surface))
      (when (and (not (eq entity moving))
                 (typep entity 'interactable)
                 (contained-p entity loc))
        (collide moving entity (make-hit entity 0.0 loc (vec 0 0)))))))

(defmethod collide ((moving moving) (block ground) hit)
  (let* ((loc (location moving))
         (vel (velocity moving))
         (pos (hit-location hit))
         (normal (hit-normal hit))
         (height (vy (bsize moving)))
         (t-s (/ (block-s block) 2)))
    (cond ((= +1 (vy normal)) (setf (svref (collisions moving) 2) block))
          ((= -1 (vy normal)) (setf (svref (collisions moving) 0) block))
          ((= +1 (vx normal)) (setf (svref (collisions moving) 3) block))
          ((= -1 (vx normal)) (setf (svref (collisions moving) 1) block)))
    (nv+ loc (v* vel (hit-time hit)))
    (nv- vel (v* normal (v. vel normal)))
    ;; Zip out of ground in case of clipping
    (cond ((and (/= 0 (vy normal))
                 (< (vy pos) (vy loc))
                 (< (- (vy loc) height)
                    (+ (vy pos) t-s)))
           (setf (vy loc) (+ (vy pos) t-s height)))
          ((and (/= 0 (vy normal))
                (< (vy loc) (vy pos))
                (< (- (vy pos) t-s)
                   (+ (vy loc) height)))
           (setf (vy loc) (- (vy pos) t-s height))))))

(defmethod collides-p ((moving moving) (block platform) hit)
  (and (< (vy (velocity moving)) 0)
       (<= (+ (vy (hit-location hit)) (floor +tile-size+ 2))
           (- (vy (location moving)) (vy (bsize moving))))))

(defmethod collide ((moving moving) (block platform) hit)
  (let* ((loc (location moving))
         (vel (velocity moving))
         (pos (hit-location hit))
         (normal (hit-normal hit))
         (height (vy (bsize moving)))
         (t-s (/ (block-s block) 2)))
    (setf (svref (collisions moving) 2) block)
    (nv+ loc (v* vel (hit-time hit)))
    (nv- vel (v* normal (v. vel normal)))
    ;; Zip
    (when (< (- (vy loc) height)
             (+ (vy pos) t-s))
      (setf (vy loc) (+ (vy pos) t-s height)))))

(defmethod collide ((moving moving) (block spike) hit)
  (die moving))

(defmethod collides-p ((moving moving) (block slope) hit)
  (let ((tt (slope (location moving) (velocity moving) (bsize moving) block (hit-location hit))))
    (when tt
      (setf (hit-time hit) tt)
      (setf (hit-normal hit) (nvunit (vec2 (- (vy2 (slope-l block)) (vy2 (slope-r block)))
                                           (- (vx2 (slope-r block)) (vx2 (slope-l block)))))))))

(defmethod collide ((moving moving) (block slope) hit)
  (let* ((loc (location moving))
         (vel (velocity moving))
         (normal (hit-normal hit))
         (slope (vec2 (vy normal) (- (vx normal)))))
    (setf (svref (collisions moving) 2) block)
    (nv+ loc (v* vel (hit-time hit)))
    ;; KLUDGE: not great yet.
    (incf (vy loc) 0.001)
    (let ((vel2 (v* slope (v. vel slope))))
      (if (and (< (vlength vel2) 0.3)
               (= (signum (vx vel2)) (signum (vx normal))))
          (vsetf vel 0 0)
          (vsetf vel (vx vel2) (vy vel2))))))

(defmethod collide ((moving moving) (platform moving-platform) hit)
  (let* ((loc (location moving))
         (vel (velocity moving))
         (pos (location platform))
         (normal (hit-normal hit))
         (bsize (bsize moving))
         (psize (bsize platform)))
    (cond ((= +1 (vy normal)) (setf (svref (collisions moving) 2) platform))
          ((= -1 (vy normal)) (setf (svref (collisions moving) 0) platform))
          ((= +1 (vx normal)) (setf (svref (collisions moving) 3) platform))
          ((= -1 (vx normal)) (setf (svref (collisions moving) 1) platform)))
    (nv+ loc (velocity platform))
    (nv+ loc (v* (v- vel (velocity platform)) 0.9 (hit-time hit)))
    (cond ((< (* (vy vel) (vy normal)) 0) (setf (vy vel) 0))
          ((< (* (vx vel) (vx normal)) 0) (setf (vx vel) 0)))
    ;; Zip out of ground in case of clipping
    (cond ((and (/= 0 (vy normal))
                (< (vy pos) (vy loc))
                (< (- (vy loc) (vy bsize))
                   (+ (vy pos) (vy psize))))
           (setf (vy loc) (+ (vy pos) (vy psize) (vy bsize) (max 0 (vy (velocity platform))))))
          ((and (/= 0 (vy normal))
                (< (vy loc) (vy pos))
                (< (- (vy pos) (vy psize))
                   (+ (vy loc) (vy bsize))))
           (setf (vy loc) (- (vy pos) (vy psize) (vy bsize))))
          ((and (/= 0 (vx normal))
                (< (vx pos) (vx loc))
                (< (- (vx loc) (vx bsize))
                   (+ (vx pos) (vx psize))))
           (setf (vx loc) (+ (vx pos) (vx psize) (vx bsize) (max 0 (vx (velocity platform))))))
          ((and (/= 0 (vx normal))
                (< (vx loc) (vx pos))
                (< (- (vx pos) (vx psize))
                   (+ (vx loc) (vx bsize))))
           (setf (vx loc) (- (vx pos) (vx psize) (vx bsize) (min 0 (vx (velocity platform)))))))))
