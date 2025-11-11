# Additional instructions

Clone the repository:

```bash
git clone git@github.com:Pace222/home-fw-monitor.git ${SERVICES_DIR:?}/fw-monitor
```

Make the firewall logs readable by everyone:

```bash
sudo chmod o+r /var/log/syslog
```
