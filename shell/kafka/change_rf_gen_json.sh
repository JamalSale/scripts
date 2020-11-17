#!/bin/bash
brokers="1,2,3"
zookeeper="localhost:2181"
kafka_home="/opt/kafka"
out_script="change_rf_run.sh"

# save topics to topics.list
"$kafka_home"/bin/kafka-topics.sh --list --zookeeper $zookeeper > topics.list

# gen json files for each topic in ./topics dir
mkdir -p ./topics
for i in `cat topics.list`; do
echo "
{\"version\":1,
 \"partitions\":[{\"topic\":\"$i\",\"partition\":0,\"replicas\":["$brokers"]}]}
" > ./topics/"$i"_topic.json
done

# gen $out_script to change RF
cat /dev/null > "$out_script" 
for i in `ls -la ./topics/*_topic.json | awk '{print $9}'`; do
echo "topic : "$i
echo "$kafka_home/bin/kafka-reassign-partitions.sh --zookeeper "$zookeeper" --reassignment-json-file ./topics/$i --execute" >> "$out_script"

done
chmod +x "$out_script"
