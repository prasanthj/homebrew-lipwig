class Lipwig < Formula
  desc "Apache Hive explain plan visualizer for Apache Tez execution engine"
  homepage "https://github.com/prasanthj/lipwig"
  url "https://github.com/prasanthj/lipwig/archive/lipwig-0.1.tar.gz"
  sha256 "3f662115d6ae070d055f1b3ff579d6b9701f7954cc1a743878fc019d35e3eb96"

  depends_on :python
  depends_on "libtool"
  depends_on "graphviz"

  def install
    libexec.install Dir["*"]
    mv libexec/"lipwig", libexec/"lipwig.sh"
    Dir.glob("#{libexec}/*.sh") do |f|
      scriptname = File.basename(f, ".sh")
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        LIPWIG_HOME=#{libexec} #{f} "$@"
      EOS
      chmod 0755, bin+scriptname
    end
  end

  test do
    (testpath/"explain.json").write <<-EOS.undent
      {"STAGE DEPENDENCIES":{"Stage-1":{"ROOT STAGE":"TRUE"},"Stage-0":{"DEPENDENT STAGES":"Stage-1"}},"STAGE PLANS":{"Stage-1":{"Tez":{"DagId:":"pjayachandran_20170424011535_6381d366-5859-404a-8b2b-fd37a77b59ce:3","DagName:":"","Vertices:":{"Map 1":{"Map Operator Tree:":[{"TableScan":{"alias:":"src","Statistics:":"Num rows:2 Data size: 12 Basic stats: COMPLETE Column stats: NONE","OperatorId:":"TS_0","children":{"Select Operator":{"expressions:":"key (type: int), value (type: string)","outputColumnNames:":["_col0","_col1"],"Statistics:":"Num rows: 2 Data size: 12 Basic stats: COMPLETE Column stats: NONE","OperatorId:":"SEL_1","children":{"Limit":{"Number of rows:":"10","Statistics:":"Num rows: 2 Data size: 12 Basic stats: COMPLETE Column stats: NONE","OperatorId:":"LIM_2","children":{"File Output Operator":{"compressed:":"false","Statistics:":"Num rows: 2 Data size: 12 Basic stats: COMPLETE Column stats: NONE","table:":{"input format:":"org.apache.hadoop.mapred.SequenceFileInputFormat","output format:":"org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat","serde:":"org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"},"OperatorId:":"FS_3"}}}}}}}}],"Execution mode:":"vectorized"}}}},"Stage-0":{"Fetch Operator":{"limit:":"10","Processor Tree:":{"ListSink":{"OperatorId:":"LIST_SINK_7"}}}}}}
    EOS

    system "#{bin}/lipwig", "-s", "-i", "explain.json", "-o", "explain.svg"
    assert_not_nil File.size? testpath/"explain.svg"
  end
end
