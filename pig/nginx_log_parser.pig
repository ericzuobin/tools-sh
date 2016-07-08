register file:/opt/hadoop/pig/pig-0.16.0/lib/piggybank.jar
DEFINE EXTRACT org.apache.pig.piggybank.evaluation.string.EXTRACT;
RAW_LOGS = LOAD '/user/hadoop/pig/access*' USING TextLoader as (line:chararray);

LOGS_BASE = FOREACH RAW_LOGS GENERATE
    FLATTEN(
      EXTRACT(line, '^(\\S+) (\\S+) (\\S+) \\[([\\w:/]+\\s[+\\-]\\d{4})\\] "(.+?) (.+)&api_key=(.+?)(&.+)? (.+?)" (\\S+) (\\S+) "([^"]*)" "([^"]*)"')
    )
    as (
      remoteAddr:    chararray,
      remoteLogname: chararray,
      user:          chararray,
      time:          chararray,
      method:        chararray,
      request:       chararray,
      api_key:       chararray,
      options:       chararray,
      httpversion:   chararray,
      status:        int,
      bytes_string:  chararray,
      referrer:      chararray,
      browser:       chararray
  );

A = FOREACH LOGS_BASE GENERATE api_key, request;
B = GROUP A BY (api_key, request);
C = FOREACH B GENERATE FLATTEN(group) as (api_key,request), COUNT(A) as count;
D = ORDER C BY api_key,count desc;
STORE D into '/user/hadoop/pig_access_out/';