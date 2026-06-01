#!/usr/bin/env bash
set -euo pipefail

# Taki Stream DZ 24/7 - YouTube Live Streaming Script
# Requires: ffmpeg, curl, jq, imagemagick
# Env vars: YOUTUBE_STREAM_KEY, YOUTUBE_API_KEY, YOUTUBE_CHANNEL_ID
# Optional: LOGO_URL

echo "=== Taki Stream DZ 24/7 ==="
echo "Checking dependencies..."

for cmd in ffmpeg curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is not installed."
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
  fc-cache -f -v 2>/dev/null || true
fi

if [ -n "${LOGO_URL:-}" ]; then
  echo "Downloading logo from LOGO_URL..."
  curl -L "$LOGO_URL" -o logo.png
  convert logo.png -resize 100x100 logo.png 2>/dev/null || \
  magick logo.png -resize 100x100 logo.png 2>/dev/null || true
else
  echo "Fetching channel logo from YouTube API..."
  CHANNEL_INFO=$(curl -s "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=${YOUTUBE_CHANNEL_ID}&key=${YOUTUBE_API_KEY}")
  AUTO_LOGO_URL=$(echo "$CHANNEL_INFO" | jq -r '.items[0].snippet.thumbnails.high.url // .items[0].snippet.thumbnails.medium.url // .items[0].snippet.thumbnails.default.url // empty')
  if [ -n "$AUTO_LOGO_URL" ]; then
    echo "Logo found: $AUTO_LOGO_URL"
    curl -L "$AUTO_LOGO_URL" -o logo.png
    convert logo.png -resize 100x100 logo.png 2>/dev/null || \
    magick logo.png -resize 100x100 logo.png 2>/dev/null || true
    echo "Logo downloaded and resized."
  else
    echo "Using blank logo."
    convert -size 100x100 xc:black logo.png 2>/dev/null || \
    magick -size 100x100 xc:black logo.png 2>/dev/null || true
  fi
fi

# ============================================================
# 1. الاخبار المضحكة DZ
# ============================================================
NEWS=(
"عاجل: مواطن لقى 50 دج في سروال قديم راه يخمم يشري بيها قناة يوتيوب"
"دراسة: 99% من الجزائريين يضغطو على تخطي الاعلان قبل ما يبدا"
"خبر: الباتري تكمل يوم كامل اذا ما حلتش فيسبوك"
"تنبيه: كي يقولك صاحبك نعيطلك بعد 5 دقايق = ما راحش يعيط"
"عاجل: واحد عطس في الدار سمعوه الجيران في الحومة اللي بعدها"
"دراسة: المشترك اللي ما يفعلش الجرس هو اللي يقول ما لحقنيش"
"عاجل: كوكب الارض يطلب من سونلغاز تخفف عليه شوية"
"دراسة: كلمة راني جاي عند الجزائري = مزال ما خرجش من الدار"
"عاجل: القهوة تاع الصباح رجعت اغلى من البترول"
"دراسة: 80% من وقت الاجتماعات يضيع في جملة وين كنا حابسين"
"عاجل: الشارجور اللي تسلفو ما يرجعش يعتبر شهيد"
"دراسة: الجزائري يعيش بلا اوكسيجين بصح ما يقدرش بلا انترنت"
"عاجل: WiFi الجيران هو الانترنت الوطني الحقيقي"
"دراسة: كلمة نرقد ساعة ونوض = 4 سوايع نوم عميق"
"خبر: اكثر كلمة تخوف الجزائري: جاك السياربي"
"عاجل: كي يقولك السيد ان شاء الله = 50% يجي 50% ما يجيش"
"دراسة: احسن منبه في العالم هو امك تقولك نوض"
"خبر: بطارية التيليفون 1% تعيش اكثر من 100%"
"عاجل: الميمز هي اللغة الرسمية الثانية في الجزائر"
"دراسة: كل جزائري عندو خال في فرنسا حتى لو ما عندوش"
"عاجل: كي تطيح الانترنت تحس روحك في جزيرة منعزلة"
"دراسة: النعاس في الحصة الاخيرة واجب وطني"
"عاجل: كي يخلاص الغاز على 12 تاع الليل = الكارثة"
"دراسة: الرقاد بعد الماكلة حلم كل جزائري"
"عاجل: كي تسلف دراهم = صاحبك ينساك للابد"
"دراسة: الضحكة تاع صح هي اللي ما عندهاش سبب"
"عاجل: الكسكسي يوم الجمعة دستور لا يناقش"
"دراسة: النت يولي سريع كي يرقدو الناس كامل"
"عاجل: المكيف في الصيف هو الاكسيجين"
"دراسة: اكثر رياضة نمارسوها هي الجري مور الحافلة"
)

# ============================================================
# 2. الجمل التحفيزية
# ============================================================
MOTIVATION=(
"ما تستناش الوقت المناسب دير لايك ضرك"
"الـ 1K الاولى صعيبة من بعد تولي ساهلة معاكم"
"كل اشتراك خطوة لقدام وكل لايك دفعة للسماء"
"اضرب اشتراك وخلي الباقي علينا حنا والزهر"
"من الصفر بدينا للقمة رايحين بيكم"
"اضغط الجرس باه ما تقولش ما علاباليش"
"انت السبة اللي مخلية البث هذا شاعل"
"ما تقولش مستحيل قول ما جربتش"
"الطريق لـ 5K يبدا بكليك منك"
"اللي يضحك معانا اليوم ينجح معانا غدوا"
"الاستمرارية هي السر وانتوما سرنا"
"ما تحقرش روحك كليك تاعك يصنع الفرق"
"اذا وصلت هنا معناها راك من العائلة"
"النجاح مع الجماعة ليه بنة اخرى"
"انت مش مجرد رقم انت خويا في القناة"
"ما تخليش الخوارزميات تغلبنا اغلبها باشتراكك"
"انت الامل تاع القناة هاذي"
"الدعم مش غير فلوس الدعم كليك"
"اليد الوحدة ما تصفقش صفق معايا"
"القناة تكبر بيكم ماشي بيا وحدي"
)

# ============================================================
# 3. الالغاز مع الاجوبة
# ============================================================
RIDDLES=(
"لغز: ما هو الشيء الذي كلما زاد نقص؟ || جواب: العمر"
"لغز: عندي اسنان بصح ما ناكلش؟ || جواب: المشط"
"لغز: ايش يدخل اخضر ويخرج اصفر؟ || جواب: الموز"
"لغز: شيء يمشي بلا رجلين؟ || جواب: الماء"
"لغز: ايش عنده قلب بلا عواطف؟ || جواب: الورقة"
"لغز: ايش يشوف بلا عيون؟ || جواب: المرآة"
"لغز: ايش يكبر كلما تاكلو؟ || جواب: الحفرة"
"لغز: ما ياخذ مكان بصح يملا الدار؟ || جواب: الضوء"
"لغز: ايش يجري بلا رجلين؟ || جواب: الوقت"
"لغز: شيء يبكي بلا عيون؟ || جواب: السماء المطر"
"لغز: ايش يكون قبالك وما تشوفوش؟ || جواب: المستقبل"
"لغز: شيء طول عمرو يكذب؟ || جواب: الميزان المعطوب"
"لغز: ايش يضحك بلا فم؟ || جواب: الزهرة"
"لغز: شيء يتبعك وما تشوفوش؟ || جواب: الظل"
"لغز: ايش يطير بلا جناحين؟ || جواب: الوقت"
)

# ============================================================
# 4. رسائل التفاعل الدوارة
# ============================================================
CTA=(
"اضرب لايك الان وساعدنا نوصلو للهدف"
"فعل الجرس باه توصلك كل جديد"
"اكتب في الكومنت وين انت من الجزائر"
"شارك البث مع صاحبك وزيد في الاجر"
"اشترك في القناة ما تخسرش والو"
"جاوب على اللغز في الكومنت"
"اكتب رقمك في الترتيب من المشتركين الاوائل"
"بارطاجي البث الان وخلي الناس تتفرج"
"اضرب ابوني وانت تتفرج ما يكلفكش والو"
"اكتب كلمة تاكي في الكومنت نشوف شكون موجود"
)

# ============================================================
# 5. احصائيات القناة
# ============================================================
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

# ============================================================
# 6. تهيئة المتغيرات الاولية
# ============================================================
CURRENT_NEWS="${NEWS[$RANDOM % ${#NEWS[@]}]}"
CURRENT_MOTIV="${MOTIVATION[$RANDOM % ${#MOTIVATION[@]}]}"
CURRENT_RIDDLE="${RIDDLES[$RANDOM % ${#RIDDLES[@]}]}"
CURRENT_CTA="${CTA[$RANDOM % ${#CTA[@]}]}"

RIDDLE_Q="${CURRENT_RIDDLE%%||*}"
RIDDLE_A="${CURRENT_RIDDLE##*||}"

LOOP_COUNT=0

# ============================================================
# 7. اللوب الرئيسي
# ============================================================
while true; do
  LOOP_COUNT=$((LOOP_COUNT + 1))

  # تحديث النصوص كل 3 دقايق
  if (( SECONDS % 180 < 32 )); then
    CURRENT_NEWS="${NEWS[$RANDOM % ${#NEWS[@]}]}"
    CURRENT_MOTIV="${MOTIVATION[$RANDOM % ${#MOTIVATION[@]}]}"
    CURRENT_CTA="${CTA[$RANDOM % ${#CTA[@]}]}"
  fi

  # تحديث اللغز كل 5 دقايق
  if (( SECONDS % 300 < 32 )); then
    CURRENT_RIDDLE="${RIDDLES[$RANDOM % ${#RIDDLES[@]}]}"
    RIDDLE_Q="${CURRENT_RIDDLE%%||*}"
    RIDDLE_A="${CURRENT_RIDDLE##*||}"
  fi

  # تحديث الاحصائيات كل ساعة
  if (( SECONDS % 3600 < 32 )); then
    STATS_JSON=$(curl -s "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$YOUTUBE_CHANNEL_ID&key=$YOUTUBE_API_KEY")
    SUBS=$(echo "$STATS_JSON" | jq -r '.items[0].statistics.subscriberCount // "0"')
    VIEWS=$(echo "$STATS_JSON" | jq -r '.items[0].statistics.viewCount // "0"')
    LEFT=$((GOAL - SUBS))
    [ "$LEFT" -lt 0 ] && LEFT=0
    PERCENT=$((SUBS * 100 / GOAL))
    [ "$PERCENT" -gt 100 ] && PERCENT=100
    echo "Updated stats: $SUBS subs / $VIEWS views"
  fi

  # فحص النت
  if ! curl -s --max-time 5 https://www.google.com >/dev/null 2>&1; then
    echo "No internet, waiting..."
    sleep 10
    continue
  fi

  # كتابة الملفات المؤقتة لـ ffmpeg
  printf '%s' "$CURRENT_NEWS"   > /tmp/taki_news.txt
  printf '%s' "$CURRENT_MOTIV"  > /tmp/taki_motiv.txt
  printf '%s' "$RIDDLE_Q"       > /tmp/taki_riddle_q.txt
  printf '%s' "$RIDDLE_A"       > /tmp/taki_riddle_a.txt
  printf '%s' "$CURRENT_CTA"    > /tmp/taki_cta.txt

  BAR_WIDTH=$((800 * PERCENT / 100))

  # تحديد ما يظهر في الشريط السفلي: لغز او CTA بالتناوب كل دقيقة
  if (( SECONDS % 120 < 60 )); then
    printf '%s' "$RIDDLE_Q"    > /tmp/taki_ticker.txt
    TICKER_LABEL="لغز تاكي"
    TICKER_COLOR="0xffd700"
  else
    printf '%s' "$CURRENT_CTA" > /tmp/taki_ticker.txt
    TICKER_LABEL="تفاعل معنا"
    TICKER_COLOR="0x00ff88"
  fi
  printf '%s' "$TICKER_LABEL" > /tmp/taki_ticker_label.txt

  # شاشة BOOM اذا وصلت للهدف
  if [ "$SUBS" -ge "$GOAL" ]; then
    ffmpeg -re -f lavfi -i "color=c=0x0a0a0a:s=1920x1080:r=1" \
    -i logo.png \
    -filter_complex "[1]scale=200:200[logo];[0][logo]overlay=(W-w)/2:(H-h)/2-100,drawtext=text='BOOM!':fontcolor=0xff0080:fontsize=150:x=(w-text_w)/2:y=200,drawtext=text='وصلنا للهدف':fontcolor=0xffd700:fontsize=80:x=(w-text_w)/2:y=380,drawtext=text='شكرا لكم جميعا':fontcolor=white:fontsize=60:x=(w-text_w)/2:y=480" \
    -c:v libx264 -preset ultrafast -tune stillimage -pix_fmt yuv420p -r 1 -g 2 -b:v 1000k -an \
    -f flv "rtmps://a.rtmp.youtube.com:443/live2/$YOUTUBE_STREAM_KEY" &
    sleep 300
    kill $! 2>/dev/null || true
  fi

  # ============================================================
  # البث العادي
  # ============================================================
  ffmpeg -re -f lavfi -i "color=c=0x0a0a0a:s=1920x1080:r=1" \
  -i logo.png \
  -filter_complex "
[1]scale=100:100[logo];[0][logo]overlay=W-w-30:30,
drawbox=x=0:y=0:w=1920:h=175:color=0x1a0050@0.95:t=fill,
drawbox=x=0:y=0:w=6:h=175:color=0x00f5ff@1:t=fill,
drawtext=text='LIVE':fontcolor=0x00ff88:fontsize=44:x=30:y=20,
drawbox=x=28:y=70:w=16:h=16:color=0x00ff88@1:t=fill,
drawtext=text='بث تاكي DZ الرسمي 24/7':fontcolor=white:fontsize=50:x=60:y=58,
drawtext=text='%{localtime\:%H\:%M\:%S}':fontcolor=0xffd700:fontsize=38:x=W-tw-100:y=68,
drawbox=x=55:y=195:w=870:h=800:color=0x0d0d2b@0.92:t=fill,
drawbox=x=55:y=195:w=870:h=6:color=0x00f5ff@1:t=fill,
drawbox=x=55:y=195:w=6:h=800:color=0x00f5ff@1:t=fill,
drawbox=x=919:y=195:w=6:h=800:color=0x00f5ff@0.3:t=fill,
drawtext=text='احصائيات القناة':fontcolor=0x00f5ff:fontsize=38:x=80:y=215,
drawbox=x=80:y=265:w=820:h=2:color=0x00f5ff@0.5:t=fill,
drawtext=text='المشتركين':fontcolor=0xaaaaaa:fontsize=30:x=80:y=285,
drawtext=text='${SUBS}':fontcolor=0xff0080:fontsize=100:x=80:y=320,
drawbox=x=80:y=440:w=820:h=2:color=0x333366@1:t=fill,
drawtext=text='الهدف\: ${GOAL} مشترك':fontcolor=white:fontsize=30:x=80:y=460,
drawbox=x=80:y=500:w=820:h=36:color=0x222244@1:t=fill,
drawbox=x=80:y=500:w=${BAR_WIDTH}:h=36:color=0x00ff88@1:t=fill,
drawtext=text='${PERCENT}%%':fontcolor=0x0a0a0a:fontsize=24:x=460:y=507,
drawtext=text='باقي ${LEFT} للهدف':fontcolor=0xffd700:fontsize=30:x=80:y=556,
drawbox=x=80:y=600:w=820:h=2:color=0x333366@1:t=fill,
drawtext=text='المشاهدات':fontcolor=0xaaaaaa:fontsize=28:x=80:y=618,
drawtext=text='${VIEWS}':fontcolor=0x00f5ff:fontsize=44:x=80:y=655,
drawbox=x=80:y=718:w=820:h=2:color=0x333366@1:t=fill,
drawtext=text='اضغط الجرس لا تفوتك':fontcolor=0xffd700:fontsize=26:x=80:y=730,
drawtext=text='كل جديد هنا اولا':fontcolor=0x00ff88:fontsize=26:x=80:y=765,
drawbox=x=80:y=820:w=820:h=2:color=0x333366@1:t=fill,
drawtext=text='شارك البث مع اصحابك':fontcolor=white:fontsize=26:x=80:y=835,
drawtext=text='وساعدنا نوصلو للهدف':fontcolor=0xaaaaaa:fontsize=26:x=80:y=870,
drawbox=x=960:y=195:w=920:h=390:color=0x0d0d2b@0.92:t=fill,
drawbox=x=960:y=195:w=920:h=6:color=0xff0080@1:t=fill,
drawbox=x=960:y=195:w=6:h=390:color=0xff0080@0.5:t=fill,
drawtext=text='اخبار DZ المضحكة':fontcolor=0xff0080:fontsize=36:x=985:y=215,
drawbox=x=985:y=263:w=870:h=2:color=0xff0080@0.5:t=fill,
drawtext=textfile='/tmp/taki_news.txt':fontcolor=white:fontsize=27:x=985:y=282:line_spacing=8,
drawbox=x=960:y=600:w=920:h=390:color=0x0d0d2b@0.92:t=fill,
drawbox=x=960:y=600:w=920:h=6:color=0x4a00e0@1:t=fill,
drawbox=x=960:y=600:w=6:h=390:color=0x4a00e0@0.5:t=fill,
drawtext=text='جرعة تحفيز':fontcolor=0x8b5cf6:fontsize=36:x=985:y=620,
drawbox=x=985:y=668:w=870:h=2:color=0x4a00e0@0.5:t=fill,
drawtext=textfile='/tmp/taki_motiv.txt':fontcolor=white:fontsize=27:x=985:y=688:line_spacing=8,
drawbox=x=985:y=820:w=870:h=2:color=0x4a00e0@0.3:t=fill,
drawtext=text='دير لايك وفعل الجرس':fontcolor=0xaaaaaa:fontsize=24:x=985:y=840,
drawbox=x=0:y=1020:w=1920:h=60:color=0x1a0050@0.97:t=fill,
drawbox=x=0:y=1020:w=1920:h=3:color=0xffd700@0.8:t=fill,
drawtext=textfile='/tmp/taki_ticker_label.txt':fontcolor=${TICKER_COLOR}:fontsize=26:x=20:y=1035,
drawtext=text=' | ':fontcolor=0x555577:fontsize=26:x=160:y=1035,
drawtext=textfile='/tmp/taki_ticker.txt':fontcolor=white:fontsize=26:x=190:y=1035
" \
  -c:v libx264 -preset ultrafast -tune stillimage -pix_fmt yuv420p -r 1 -g 2 -b:v 1200k \
  -c:a aac -b:a 32k -ar 44100 \
  -f flv "rtmps://a.rtmp.youtube.com:443/live2/$YOUTUBE_STREAM_KEY" || true

  sleep 30
done
