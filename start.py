import time
from datetime import datetime

while True:
    message = 'It\'s %s' % datetime.now().strftime('%H:%M:%S')
    print(message, flush=True)
    time.sleep(10)
