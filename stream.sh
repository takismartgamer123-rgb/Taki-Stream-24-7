#!/usr/bin/env bash
set -euo pipefail

# Taki Stream DZ 24/7 - YouTube Live Streaming Script
# Requires: ffmpeg, curl, jq, imagemagick
# Environment variables needed:
#   YOUTUBE_STREAM_KEY  - Your YouTube live stream key
#   YOUTUBE_API_KEY     - YouTube Data API v3 key
#   YOUTUBE_CHANNEL_ID  - Your YouTube channel ID
#   LOGO_URL            - (Optional) Override logo URL — auto-fetched from YouTube if not set

echo "=== Taki Stream DZ 24/7 ==="
echo "Checking dependencies..."

for cmd in ffmpeg curl jq convert; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is not installed. Install it and try again."
    exit 1
  fi
done

echo "Checking environment variables..."
: "${YOUTUBE_STREAM_KEY:?Need YOUTUBE_STREAM_KEY set}"
: "${YOUTUBE_API_KEY:?Need YOUTUBE_API_KEY set}"
: "${YOUTUBE_CHANNEL_ID:?Need YOUTUBE_CHANNEL_ID set}"

echo "Setting up fonts and logo..."
mkdir -p ~/.fonts
if [ ! -f ~/.fonts/NotoColorEmoji.ttf ]; then
  curl -L "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf" \
    -o ~/.fonts/NotoColorEmoji.ttf
  fc-cache -f -v
fi

if [ -n "${LOGO_URL:-}" ]; then
  echo "Downloading logo from LOGO_URL..."
  curl -L "$LOGO_URL" -o logo.png
  magick logo.png -resize 100x100 logo.png || true
else
  echo "Fetching channel logo from YouTube API..."
  CHANNEL_INFO=$(curl -s "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=${YOUTUBE_CHANNEL_ID}&key=${YOUTUBE_API_KEY}")
  AUTO_LOGO_URL=$(echo "$CHANNEL_INFO" | jq -r '.items[0].snippet.thumbnails.high.url // .items[0].snippet.thumbnails.medium.url // .items[0].snippet.thumbnails.default.url // empty')
  if [ -n "$AUTO_LOGO_URL" ]; then
    echo "Logo found: $AUTO_LOGO_URL"
    curl -L "$AUTO_LOGO_URL" -o logo.png
    magick logo.png -resize 100x100 logo.png || true
    echo "Logo downloaded and resized successfully."
  else
    echo "Could not fetch logo from YouTube API, using blank logo."
    magick -size 100x100 xc:black logo.png || true
  fi
fi

# 1. الاخبار المضحكة DZ 100 خبر
NEWS=(
"عاجل: مواطن لقى 50 دج في سروال قديم، راه يخمم يشري بيها قناة يوتيوب"
"دراسة: 99% من الجزائريين يضغطو على تخطي الاعلان قبل ما يبدا"
"خبر مفرح: الباتري تكمل يوم كامل اذا ما حلتش فيسبوك"
"تنبيه: كي يقولك صاحبك نعيطلك بعد 5 دقايق = ما راحش يعيط"
"عاجل: واحد عطس في الدار، سمعوه الجيران في الحومة اللي بعدها"
"دراسة: المشترك اللي ما يفعلش الجرس هو نفسو اللي يقول ما لحقنيش"
"خبر: جماعة الكونيكسيون الضعيفة راهم يحملو البث تاعنا 2019"
"عاجل: كوكب الارض يطلب من سونلغاز تخفف عليه شوية"
"دراسة: كلمة راني جاي عند الجزائري = مزال ما خرجش من الدار"
"خبر: واحد شرى تيليفون جديد باه يصور بيه التيليفون القديم"
"تنبيه: اذا شفت جارك يجري الصباح، ماشي رياضة، راه يلحق في الطرام"
"عاجل: القهوة تاع الصباح رجعت اغلى من البترول"
"دراسة: 80% من وقت الاجتماعات يضيع في جملة وين كنا حابسين"
"خبر: واحد دار وضع الطيران في تيليفونو، التيليفون طار صح"
"عاجل: الشارجور اللي تسلفو ما يرجعش، يعتبر شهيد"
"دراسة: الجزائري يقدر يعيش بلا اوكسيجين بصح ما يقدرش بلا انترنت"
"خبر: طفل صغير قال لباباه نشريلك فيراري كي نكبر، باباه راه يستنى 2040"
"عاجل: كي تطيحلك الملعقة = عندك ضياف، كي يطيح التيليفون = عندك مصيبة"
"دراسة: 70% من ليكور نتاع الجامعة راحو في تصاور السلايدات"
"خبر: واحد راح يشري خبز، رجع بعد 3 سوايع علاش؟ تلاقى واحد يعرفو"
"عاجل: WiFi الجيران هو الانترنت الوطني الحقيقي"
"دراسة: كلمة نرقد ساعة ونوض = 4 سوايع نوم عميق"
"خبر: اكثر كلمة تخوف الجزائري: جاك السياربي"
"عاجل: الكلافيي تاعك يعرف كلمة السر اكثر منك"
"دراسة: المشي للصالون يعتبر رياضة عند بعض الناس"
"خبر: واحد دخل لـ Google باه يكتب Google"
"عاجل: كي يقولك السيد ان شاء الله = 50% يجي 50% ما يجيش"
"دراسة: احسن منبه في العالم هو امك تقولك نوض"
"خبر: بطارية التيليفون 1% تعيش اكثر من 50% الى 100%"
"عاجل: الميمز هي اللغة الرسمية الثانية في الجزائر"
)

# 2. الجمل التحفيزية 100 جملة
MOTIVATION=(
"ما تستناش الوقت المناسب، دير لايك ضرك"
"الـ 1K الاولى صعيبة، من بعد تولي ساهلة معاكم"
"كل اشتراك = خطوة لقدام، كل لايك = دفعة للسماء"
"قالو النجاح ما يجيش وحدو، يجي مع جماعة كيفكم"
"اضرب اشتراك وخلي الباقي علينا حنا والزهر"
"اليوم متابع، غدوا انت المول"
"من الصفر بدينا، للقمة رايحين بيكم"
"اضغط الجرس، باه ما تقولش ما علاباليش"
"انت السبة اللي مخلية البث هذا شاعل"
"احلم كبير، واشترك اكبر"
"ما تقولش مستحيل، قول ما جربتش"
"كل دقيقة معانا = دعم ما يتقدرش بثمن"
"الطريق لـ 5K يبدا بكليك منك"
"كون انت التغيير اللي حاب تشوفو في اليوتيوب"
"اللي يضحك معانا اليوم، ينجح معانا غدوا"
"الاستمرارية هي السر، وانتوما سرنا"
"ما تحقرش روحك، كليك تاعك يصنع الفرق"
"اذا وصلت هنا، معناها راك من العائلة"
"النجاح مع الجماعة ليه بنة اخرى"
"اشترك و ردها عليا اذا ما نجحناش مع بعض"
"كل فيديو تشوفو هو خطوة في الحلم تاعنا"
"انت مش مجرد رقم، انت خويا في القناة"
"اللي يدعم اليوم، يتذكر غدوا كي نطلعو"
"ما تخليش الخوارزميات تغلبنا، اغلبها باشتراكك"
"انت الامل تاع القناة هاذي"
"نضحكو اليوم و ننجحو غدوا"
"الدعم مش غير فلوس، الدعم كليك"
"كون السبب في فرحة واحد اليوم"
"اليد الوحدة ما تصفقش، صفق معايا"
"القناة تكبر بيكم ماشي بيا وحدي"
)

# 3. احصائيات القناة
echo "Fetching channel stats..."
STATS_JSON=$(curl -s "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$YOUTUBE_CHANNEL_ID&key=$YOUTUBE_API_KEY")
SUBS=$(echo "$STATS_JSON" | jq -r '.items[0].statistics.subscriberCount // "0"')
VIEWS=$(echo "$STATS_JSON" | jq -r '.items[0].statistics.viewCount // "0"')
GOAL=5000
LEFT=$((GOAL - SUBS))
[ "$LEFT" -lt 0 ] && LEFT=0
PERCENT=$((SUBS * 100 / GOAL))
[ "$PERCENT" -gt 100 ] && PERCENT=100

echo "Subscribers: $SUBS / $GOAL  |  Views: $VIEWS"
echo "Starting stream loop..."

CURRENT_NEWS="${NEWS[$RANDOM % ${#NEWS[@]}]}"
CURRENT_MOTIV="${MOTIVATION[$RANDOM % ${#MOTIVATION[@]}]}"

# 4. اللوب الرئيسي
while true; do
  # تحديث كل 3 دقايق
  if (( SECONDS % 180 < 5 )); then
    CURRENT_NEWS="${NEWS[$RANDOM % ${#NEWS[@]}]}"
    CURRENT_MOTIV="${MOTIVATION[$RANDOM % ${#MOTIVATION[@]}]}"

    # تحديث الاحصائيات كل ساعة
    if (( SECONDS % 3600 < 5 )); then
      STATS_JSON=$(curl -s "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$YOUTUBE_CHANNEL_ID&key=$YOUTUBE_API_KEY")
      SUBS=$(echo "$STATS_JSON" | jq -r '.items[0].statistics.subscriberCount // "0"')
      VIEWS=$(echo "$STATS_JSON" | jq -r '.items[0].statistics.viewCount // "0"')
      LEFT=$((GOAL - SUBS))
      [ "$LEFT" -lt 0 ] && LEFT=0
      PERCENT=$((SUBS * 100 / GOAL))
      [ "$PERCENT" -gt 100 ] && PERCENT=100
    fi
  fi

  # فحص النت
  if ! curl -s --max-time 5 https://www.google.com >/dev/null 2>&1; then
    echo "No internet, waiting..."
    sleep 10
    continue
  fi

  # كتابة النصوص الديناميكية في ملفات مؤقتة لتجنب مشاكل الترميز مع ffmpeg
  printf '%s' "$CURRENT_NEWS"  > /tmp/taki_news.txt
  printf '%s' "$CURRENT_MOTIV" > /tmp/taki_motiv.txt

  BAR_WIDTH=$((800 * PERCENT / 100))

  # شاشة BOOM اذا وصلت للهدف
  if [ "$SUBS" -ge "$GOAL" ]; then
    ffmpeg -re -f lavfi -i "color=c=0x0a0a0a:s=1920x1080:r=1" \
    -i logo.png \
    -filter_complex "[1]scale=200:200[logo];[0][logo]overlay=(W-w)/2:(H-h)/2,drawtext=text='BOOM!':fontcolor=0xff0080:fontsize=150:x=(w-text_w)/2:y=(h-text_h)/2-50,drawtext=text='وصلنا ${GOAL} مشترك':fontcolor=white:fontsize=60:x=(w-text_w)/2:y=(h-text_h)/2+100" \
    -c:v libx264 -preset ultrafast -tune stillimage -pix_fmt yuv420p -r 1 -g 2 -b:v 1000k -an \
    -f flv "rtmps://a.rtmp.youtube.com:443/live2/$YOUTUBE_STREAM_KEY" &
    sleep 300
    kill $! 2>/dev/null || true
  fi

  # البث العادي
  ffmpeg -re -f lavfi -i "color=c=0x0a0a0a:s=1920x1080:r=1" \
  -i logo.png \
  -filter_complex "[1]scale=100:100[logo];[0][logo]overlay=W-w-50:50,drawbox=x=0:y=0:w=1920:h=180:color=0x4a00e0@0.9:t=fill,drawtext=text='LIVE':fontcolor=0x00ff88:fontsize=48:x=80:y=65,drawtext=text='بث تاكي الرسمي 24/7':fontcolor=white:fontsize=55:x=300:y=60,drawtext=text='%{localtime}':fontcolor=0xffd700:fontsize=40:x=W-tw-80:y=70,drawbox=x=60:y=220:w=900:h=800:color=0x1a1a2e@0.85:t=fill,drawbox=x=60:y=220:w=900:h=80:color=0x00f5ff@1:t=fill,drawtext=text='احصائيات القناة':fontcolor=0x0a0a0a:fontsize=45:x=100:y=235,drawtext=text='Taki':fontcolor=0x00f5ff:fontsize=60:x=100:y=350,drawtext=text='المشتركين':fontcolor=white:fontsize=35:x=100:y=430,drawtext=text='${SUBS}':fontcolor=0xff0080:fontsize=90:x=100:y=480,drawtext=text='الهدف\: ${GOAL}':fontcolor=white:fontsize=35:x=100:y=620,drawbox=x=100:y=680:w=800:h=40:color=0x333333@1:t=fill,drawbox=x=100:y=680:w=${BAR_WIDTH}:h=40:color=0x00ff88@1:t=fill,drawtext=text='${PERCENT}%%':fontcolor=white:fontsize=30:x=480:y=685,drawtext=text='باقي ${LEFT} للهدف':fontcolor=0xffd700:fontsize=35:x=100:y=750,drawtext=text='${VIEWS} مشاهدة':fontcolor=0x00f5ff:fontsize=35:x=100:y=820,drawbox=x=1040:y=200:w=800:h=650:color=0x1a1a2e@0.85:t=fill,drawbox=x=1040:y=200:w=800:h=80:color=0xff0080@1:t=fill,drawtext=text='اخبار DZ المضحكة':fontcolor=white:fontsize=45:x=1100:y=215,drawtext=textfile='/tmp/taki_news.txt':fontcolor=white:fontsize=30:x=1080:y=320,drawbox=x=1080:y=500:w=720:h=5:color=0x4a00e0@1:t=fill,drawtext=text='جرعة تحفيز\:':fontcolor=0x00ff88:fontsize=35:x=1080:y=540,drawtext=textfile='/tmp/taki_motiv.txt':fontcolor=white:fontsize=30:x=1080:y=600,drawtext=text='دير لايك | كومنت':fontcolor=0xaaaaaa:fontsize=30:x=1080:y=750,drawbox=x=0:y=1020:w=1920:h=60:color=0x4a00e0@0.9:t=fill,drawtext=text='لغز تاكي\: ما هو الشيء الذي كلما زاد نقص؟':fontcolor=white:fontsize=35:x=100:y=1035,drawtext=text='جاوب في الكومنت | لغز جديد كل 30 دقيقة':fontcolor=0xffd700:fontsize=28:x=100:y=1075" \
  -c:v libx264 -preset ultrafast -tune stillimage -pix_fmt yuv420p -r 1 -g 2 -b:v 1000k \
  -c:a aac -b:a 32k -ar 44100 \
  -f flv "rtmps://a.rtmp.youtube.com:443/live2/$YOUTUBE_STREAM_KEY" || true

  sleep 30
done
