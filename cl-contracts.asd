(asdf:defsystem #:cl-contracts
  :depends-on (#:alexandria #:bordeaux-threads)
  :components ((:module "src"
                :components ((:file "package")
                             (:file "cl-contracts" :depends-on ("package"))))))