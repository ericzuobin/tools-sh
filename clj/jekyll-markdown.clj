(ns net.zuobin.study
  (:gen-class :main true)
  (:use [clojure.java.io]))

(defn endComment?
  "是否是注释最后"
  [li]
  (let [line (.trim li)] (if (and (= (.lastIndexOf line "~") (- (.length line) 1)) (not= (.lastIndexOf line "~") -1))
     "{% endhighlight %}\n"
     (println-str "{% highlight " (.substring line (+ (.lastIndexOf line "~") 1) (.length line)) " %}"))))

(defn writeFile
  "写文件操作"
  [line wtr]
  (if (.startsWith line "~~~")
    (.write wtr (endComment? line))
    (.write wtr (println-str line)))
  )

(defn fread [filename blogName header]
  (with-open [rdr (reader filename) wtr (writer blogName :append true)]
    (.write wtr header)
    (doseq [line (line-seq rdr)]
      (writeFile line wtr))))

(defn getUserDir []
  (System/getProperty "user.dir"))

(defn md? [filename]
  (let [fileLenth (.length filename)]
    (if (> fileLenth 3)
      ;.md后缀结尾必须大于3
      (if (= (.substring filename (- fileLenth 3) fileLenth) ".md") true) false)))

(defn checkArgs [& args]
  (let [filename (first args)]
    (condp = (first filename)
      nil (do (println "请输入当前目录下所需转换的文件名...") false)
      "help" (do (println "请输入待转换文件名(.md),可选参数[Title,分类,是否转载]") false)
      (do (if (md? (first filename)) true (do (println "非.md文件") false)))
      )
    ))

(defn formateDate
  "格式化时间！"
  [ss]
  (if ss
    (.format (java.text.SimpleDateFormat. "yyyy-MM-dd") (java.util.Date.))
    (.format (java.text.SimpleDateFormat. "yyyy-MM-dd hh:mm") (java.util.Date.)))
  )

(defn formateTitle
  "获取markdown博客文件的头信息！"
  [& args]
  (format "---\nlayout: post\ntitle: \"\" \nme: true\nmodified: %s \ndate: %s \ntags: [] \ncategories:  [] \ndescription: \"\"\n---\n\n"
          (formateDate true) (formateDate false))
  )

(defn getFileBlogName
  "获取输出的markdown博客文件名！"
  [& args]
  (str (formateDate true) "-" (first (first args))))

(defn getFileName
  "获取参数传递的文件名。"
  [& args]
  (first (first args))
  )

(defn -main
  [& args]
  (if (checkArgs args) (fread (getFileName args) (getFileBlogName args) (formateTitle args))))