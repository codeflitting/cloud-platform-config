#!/usr/bin/env bash

# USAGE:
# bash list_avaliable_hadoop_codecs.sh

if [[ -z `which hadoop 2>/dev/null` ]]; then
  echo "hadoop command not found!"
  exit 1
fi

hadoop checknative 2>/dev/null


CP=$(hadoop classpath)
JLIB="-Djava.library.path=/usr/lib/hadoop/lib/native:/usr/lib/hbase/lib/native/Linux-amd64-64"

J=$(cat <<- EOF
import java.util.List;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.compress.CompressionCodec;
import org.apache.hadoop.io.compress.CompressionCodecFactory;
public class ListCodecs {
  public static void main(String[] args) throws Throwable {
    List<Class<? extends CompressionCodec>> codecClasses = CompressionCodecFactory.getCodecClasses(new Configuration());
    System.out.println("\navailable codecs:\n");
    for (Class<? extends CompressionCodec> clazz : codecClasses) {
      String str = "";
      String codecName = clazz.getSimpleName();
      if (codecName.endsWith("Codec")) {
        codecName = codecName.substring(0, codecName.length() - "Codec".length());
        str = codecName.toLowerCase();
      }
      String ext = clazz.newInstance().getDefaultExtension();
      str = str + "\t\t" + ext + "\t" + (ext.length()<8 ? "\t":"") + clazz.getName();
      System.out.println(str);
    }
    System.out.println("\n");
  }
}
EOF
)
cd /tmp
echo $J > ListCodecs.java
javac -cp $CP ListCodecs.java
java $JLIB -cp .:$CP ListCodecs 2>/dev/null
rm -f ListCodecs.*