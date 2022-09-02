HOST_IF=$(ip route|grep default|head -n1|cut -d' ' -f5)
HOST_IP=$(ip a|grep "$HOST_IF$"|head -n1|awk '{print $2}'|cut -d'/' -f1)

echo $HOST_IP