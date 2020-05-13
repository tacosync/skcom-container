import os
import time
from datetime import datetime

# 啟動 Xvfb
os.system('nohup Xvfb :1 -screen 0 1600x1200x16 > /dev/null 2>&1 &')

# 無窮迴圈, 讓 Container 維持運作中
prev = 0
while True:
    curr = time.time()
    if (curr - prev) > 60:
        prev = curr
        message = 'It\'s %s' % datetime.now().strftime('%H:%M:%S')
        print(message, flush=True)
    time.sleep(1)
