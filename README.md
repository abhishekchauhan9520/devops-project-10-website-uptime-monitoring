# Project 10 — Website Uptime Monitoring with Cron Jobs

A small Linux automation project that periodically checks whether a website responds successfully and records the result.

## What it demonstrates

- Bash scripting
- `curl` HTTP checks
- Connection and request timeouts
- Explicit success/failure exit codes
- UTC timestamped monitoring logs
- Cron scheduling
- Safe parameter validation
- Reusable command-line arguments
- Basic automated testing

## Run manually

```bash
chmod +x monitor/check_site.sh
./monitor/check_site.sh https://example.com
```

Optional timeout and log file:

```bash
./monitor/check_site.sh https://example.com 5 /tmp/site-monitor.log
```

### Exit codes

- `0` — site responded successfully
- `1` — site check failed
- `2` — invalid command-line input or setup error

## Cron

The repository contains `crontab.txt` with a five-minute schedule. Before installing it, replace the example URL and choose a real absolute path for the script and log file.

```cron
*/5 * * * * /opt/project-10/monitor/check_site.sh https://example.com 10 /var/log/project-10-uptime.log
```

Install for the current user with:

```bash
crontab -e
```

Do not blindly install the example line with root privileges; adapt the path and permissions for your host first.

## Testing

Run:

```bash
tests/test_check_site.sh
```

The test suite starts a temporary local HTTP server and verifies both successful and failed checks without relying on the public internet.

## GitHub Actions

CI runs Bash syntax checks, ShellCheck, and the local HTTP-based smoke tests on every push and pull request.
