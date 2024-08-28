city="Shanghai_103"
region="Henan"
city="Zhengzhou"
org="CHINA UNICOM China169 Backbone"
is_domain="true"
stream="udp/239.45.1.4:5140"
channel_key="上海"

url_fofa=$(echo  '"udpxy" && region="'${region}" && city="'${city}'" && org="'${org}'e" && is_domain='${is_domain}'"' | base64 |tr -d '\n')
url_fofa="https://fofa.info/result?qbase64="$url_fofa

# fofa 检索
echo "请求地址为："${url_fofa}
echo "=============== 从 fofa 检索 ip/域名 + 端口 ================="
curl -X GET "$url_fofa" > test.html
grep -E '^\s+(\w+\.)+\w+:' test.html | grep -oE '(\w+.)+\w+:.*$' > ip.txt
rm test.html
echo "已提取 ip/域名及端口："
cat ip.txt

# 使用 curl 对 ip.txt 进行连通性测试并排序输出到 result.ip
while read line; do
    curl_result=$(curl -o /dev/null -s -w "connect time:%{time_connect}s, time_total:%{time_total}s, speed_download:%{speed_download} bytes/s\n" "${line}/status")
    echo "当前行内容：${line}：curl 结果：${curl_result}"
done < ip.txt | sort -t ':' -k4 -nr > ip.txt
cat ip.txt

# 读取 ip.txt 的第一行
first_line=$(head -n 1 ip.txt)

# 进行替换操作
sed -i "s/ip:port/${first_line}/" "./template/${city}.txt"
