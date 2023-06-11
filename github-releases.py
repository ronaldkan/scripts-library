import os
import sys
import requests
import pytz
import logging

from datetime import datetime, timedelta
from slack_sdk.webhook import WebhookClient

# init logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s.%(msecs)03d | %(levelname)s | %(funcName)s | %(message)s',
    datefmt='%Y-%m-%dT%H:%M:%S',
)
logger = logging.getLogger(__name__)

# init slack webhook
if not 'SLACK_WEBHOOK_BOT_APP_RELEASES' in os.environ:
  logger.error('$SLACK_WEBHOOK_BOT_APP_RELEASES is not defined.')
  sys.exit(1)
slack_url = os.environ['SLACK_WEBHOOK_BOT_APP_RELEASES']
slack_webhook = WebhookClient(slack_url)

# init variables
new_apps = 'New releases from last month'
current_date = datetime.now(pytz.timezone('Asia/Singapore'))

# SERVICE_REPOS should be in a comma separated string
if 'SERVICE_REPOS' in os.environ:
  repos = os.environ['SERVICE_REPOS'].replace(' ', '').split(',')
  for repo in repos:
    # repo should be in the format of <github_repo>/<app_name> eg fluxcd/flux2
    url = f'https://api.github.com/repos/{repo}/releases/latest'
    # TZ should be set to singapore since the periodic pipeline will run in SGT, likewise the for current_date
    r = requests.get(url = url, headers={"Time-Zone": "Asia/Singapore"})
    data = r.json()
    date = datetime.strptime(data['published_at'], "%Y-%m-%dT%H:%M:%SZ")
    a = date.date()
    b = current_date.date() - timedelta(days=1)
    # new releases should be in the same year and month of previous month
    if (a.year == b.year and a.month == b.month):
      new_tag_name = data['tag_name']
      new_apps += f'\n• {repo} - (https://github.com/{repo}/releases/tag/{new_tag_name})'
  slack_webhook.send(text=new_apps)
