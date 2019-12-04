# from https://github.com/jupyterhub/jupyterhub/wiki/Run-jupyterhub-as-a-system-service

cp skinnywms /etc/init.d/
chmod +x /etc/init.d/skinnywms
# Create a default config folder
mkdir -p /etc/skinnywms
# TODO: copy config to config dir
# Reload systemctl daemon to notice the init.d script
systemctl daemon-reload
# Start jupyterhub
service skinnywms start
# Stop jupyterhub
#service jupyterhub stop
# Start jupyterhub on boot
update-rc.d skinnywms defaults