(load "scanner.lisp")
(load "parser.lisp")
(load "generator.lisp")

(defvar *index* 0)

(defun scanner-test (code-file &optional log-file)
  (if log-file
      (with-open-file (stream log-file :direction :output :if-exists :supersede)
	(write-to-stream (scanner code-file) stream))
      (write-to-stream (scanner code-file))))

(defun tree-to-graph (source-file &optional (target-file "graph.dot"))
  (let ((graph (cl-graph:make-graph 'cl-graph:dot-graph
				    :default-edge-type :directed)))
    (make-pairs (parse-file source-file)
	        (lambda (pair)
		  (let ((vertex1 (cl-graph:add-vertex graph
						      (car (car pair))
						      :dot-attributes (list :label (second (car pair)))))
			(vertex2 (cl-graph:add-vertex graph
						      (car (second pair))
						      :dot-attributes (list :label (second (second pair))))))
		    (cl-graph:add-edge-between-vertexes graph
							vertex1
							vertex2
							:dot-attributes '(:label "")))))
    (cl-graph:graph->dot graph target-file)))

(defun translate-to-file (source-file target-file)
  (with-open-file (stream
		   target-file
		   :direction :output
		   :if-exists :supersede
		   :if-does-not-exist :create)
    (translate source-file stream)))

(defun inc () (incf *index*))

(defun make-pairs (lst fn)
  (let ((index *index*))
    (mapc (lambda (elem)
	    (inc)
	    (funcall fn (if (listp elem)
			    (prog1
				(list (list index (car lst)) (list *index* (car elem)))
			      (make-pairs elem fn))
			    (list (list index (car lst)) (list *index* elem)))))
	  (cdr lst))))

(defun write-to-stream (rezult &optional (stream t))
  (format stream "~5S ~7S ~15S ~S~%~%" 'Line 'Column 'Symbol 'Type)
  (mapc (lambda (lexem)
	  (let ((value (lexem-value (second lexem)))
		(line (lexem-row (second lexem)))
		(column (lexem-column (second lexem)))
		(type (car lexem)))
	    (format stream "~5S ~7S ~15S ~S~%" line column value type)))
	rezult))

(defun run-tests-scanner ()
  (format t "TEST 1:~%")
  (format t "~S~%~%" (scanner-test "tests/scanner/true1.txt"))
  (format t "TEST 2:~%")
  (format t "~S~%~%" (scanner-test "tests/scanner/true2.txt"))
  (format t "TEST 3:~%")
  (format t "~S~%~%"(scanner-test "tests/scanner/true3.txt"))
  (format t "TEST 4:~%")
  (format t "~S~%~%" (scanner-test "tests/scanner/false1.txt"))
  (format t "TEST 5:~%")
  (format t "~S~%~%"(scanner-test "tests/scanner/false2.txt"))
  (format t "TEST 6:~%")
  (format t "~S~%~%" (scanner-test "tests/scanner/false3.txt"))
  (format t "TEST 7:~%")
  (format t "~S~%~%" (scanner-test "tests/scanner/false4.txt"))
  t)

(defun run-tests-parser ()
  (format t "TEST 1:~%")
  (format t "~S~%~%" (parse-file "tests/parser/true1.txt"))
  (format t "TEST 2:~%")
  (format t "~S~%~%" (parse-file "tests/parser/true2.txt"))
  (format t "TEST 3:~%")
  (format t "~S~%~%"(parse-file "tests/parser/true3.txt"))
  (format t "TEST 4:~%")
  (format t "~S~%~%"(parse-file "tests/parser/true4.txt"))
  (format t "TEST 5:~%")
  (format t "~S~%~%"(parse-file "tests/parser/true5.txt"))
  (format t "TEST 6:~%")
  (format t "~S~%~%" (parse-file "tests/parser/false1.txt"))
  (format t "TEST 7:~%")
  (format t "~S~%~%"(parse-file "tests/parser/false2.txt"))
  (format t "TEST 8:~%")
  (format t "~S~%~%" (parse-file "tests/parser/false3.txt"))
  (format t "TEST 9:~%")
  (format t "~S~%~%" (parse-file "tests/parser/false4.txt"))
   (format t "TEST 11:~%")
  (format t "~S~%~%" (parse-file "tests/parser/false6.txt"))
   (format t "TEST 12:~%")
  (format t "~S~%~%" (parse-file "tests/parser/false7.txt"))
  t)

(defun do-graphs ()
  (tree-to-graph "tests/parser/true1.txt" "tests/parser/graph1.dot")
  (tree-to-graph "tests/parser/true2.txt" "tests/parser/graph2.dot")
  (tree-to-graph "tests/parser/true3.txt" "tests/parser/graph3.dot")
  (tree-to-graph "tests/parser/true4.txt" "tests/parser/graph4.dot")
  (tree-to-graph "tests/parser/true5.txt" "tests/parser/graph5.dot")
  t)
