(in-package #:org.shirakumo.fraf.leaf)

(defclass region (layered-container entity)
  ((author :initform "Anonymous" :initarg :author :accessor author)
   (version :initform "0.0.0" :initarg :version :accessor version)
   (description :initform "" :initarg :description :accessor description)
   (preview :initform NIL :initarg :preview :accessor preview))
  (:default-initargs
   :name (error "NAME required.")
   :layers +layer-count+))

(defclass version () ())

(defgeneric load-region (packet scene))
(defgeneric save-region (region packet &key version &allow-other-keys))

(defmethod save-region ((scene scene) target &rest args)
  (apply #'save-region (unit 'region scene) target args))

(defmethod save-region :around (region target &rest args &key (version T))
  (apply #'call-next-method region target :version (ensure-version version) args))

(defmethod save-region (region (pathname pathname) &key version (if-exists :supersede))
  (with-packet (packet pathname :direction :output :if-exists if-exists)
    (save-region region packet :version version)))

(defmethod save-region (region (packet packet) &key version)
  (with-packet-entry (stream "meta.lisp" packet :element-type 'character)
    (princ* (list :identifier 'region :version (type-of version)) stream)
    (princ* (encode-payload region NIL packet version) stream)))

(defmethod load-region ((pathname pathname) scene)
  (with-packet (packet pathname :direction :input)
    (load-region packet scene)))

(defmethod load-region ((packet packet) (scene scene))
  (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
    (let ((region (decode-payload
                   info (type-prototype 'region) packet
                   (destructuring-bind (&key identifier version) header
                     (assert (eql 'region identifier))
                     (coerce-version version)))))
      (enter region scene))))
