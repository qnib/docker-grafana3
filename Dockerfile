###### QNIBTerminal Image
FROM qnib/syslog

ENV DS_QCOLLECT=qcollect
ADD etc/yum.repos.d/grafana.repo /etc/yum.repos.d/
RUN echo "2016-06-14.1" \ 
 && dnf clean all \
 && dnf install -y grafana \
 && mkdir -p /opt/qnib/grafana3/dashboards/
ADD etc/supervisord.d/*.ini /etc/supervisord.d/
ADD etc/grafana/grafana.ini /etc/grafana/grafana.ini.new
ADD var/lib/grafana/grafana.db /var/lib/grafana/
ADD etc/consul.d/grafana3.json /etc/consul.d/
ADD opt/qnib/grafana3/bin/start.sh /opt/qnib/grafana3/bin/
ADD opt/qnib/grafana3/dashboards/docker-stats.json \
    opt/qnib/grafana3/dashboards/prometheus.json \
    /opt/qnib/grafana3/dashboards/
