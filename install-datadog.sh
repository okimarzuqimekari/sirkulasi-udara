export DD_AGENT_MAJOR_VERSION=changme
export DD_API_KEY=changme
export DD_SITE="datadoghq.com"

bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

mkdir /opt/datadog-agent/bin/agent/dist/conf.d
rm -rf /var/log/datadog/*

chown -R dd-agent:dd-agent /etc/datadog-agent/
systemctl restart datadog-agent
