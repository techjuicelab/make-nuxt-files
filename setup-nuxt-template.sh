#!/bin/zsh

# 오류 발생 시 핸들링을 위한 설정 및 에러 핸들러 정의
set -e
handle_error() {
  echo "❌ 오류 발생: $BASH_COMMAND (라인: $LINENO)"
  exit 1
}
trap handle_error ERR

# 파일 목록을 다른 파일에서 읽어오기
FILE_INPUT="files.list"
TEMPLATE_FILE="default.template"

if [ ! -f "$FILE_INPUT" ]; then
  echo "⚠️ 파일 목록을 담은 $FILE_INPUT 파일이 존재하지 않습니다. 먼저 파일을 생성해주세요."
  exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "⚠️ 템플릿 파일이 존재하지 않습니다: $TEMPLATE_FILE"
  exit 1
fi

FILE_LIST=$(cat "$FILE_INPUT")

# 템플릿 불러오기 함수
extract_template() {
  local section=$1
  awk "/#### ${section} ####/{flag=1; next} /####/{flag=0} flag" "$TEMPLATE_FILE"
}

# app.vue가 입력 목록에 포함된 경우 삭제 후 APP_TEMPLATE 적용
if echo "$FILE_LIST" | grep -q "app.vue"; then
  echo "🔄 app.vue를 재생성합니다..."
  rm -f app.vue
  extract_template "APP_TEMPLATE" > app.vue
  echo "✅ app.vue 파일이 생성되었습니다."
fi

# 모든 폴더를 미리 생성하여 에러 방지
while IFS= read -r FILE_PATH; do
  if [ -n "$FILE_PATH" ]; then
    DIR_PATH=$(dirname "$FILE_PATH")
    if [ ! -d "$DIR_PATH" ]; then
      mkdir -p "$DIR_PATH"
      echo "📂 폴더 생성: $DIR_PATH"
    fi
  fi
done <<< "$FILE_LIST"

# 파일 생성 및 기본 내용 입력
while IFS= read -r FILE_PATH; do
  # 파일 경로가 비어 있으면 건너뜁니다.
  [ -z "$FILE_PATH" ] && continue

  # app.vue는 이미 처리되었으므로 건너뜁니다.
  if [ "$FILE_PATH" = "app.vue" ]; then
    continue
  fi

  touch "$FILE_PATH"
  FILE_NAME=$(basename "$FILE_PATH")
  echo "📝 파일 생성: $FILE_PATH"

  # 파일 유형별 기본 템플릿 적용
  case "$FILE_PATH" in
    layouts/*.vue)
      FILE_BASENAME=$(basename "$FILE_PATH" .vue)
      LOWER_FILE_BASENAME=${FILE_BASENAME:l}
      extract_template "LAYOUT_TEMPLATE" | sed "s/{{FILENAME}}/$LOWER_FILE_BASENAME/" > "$FILE_PATH"
      ;;
    components/*.vue)
      FILE_BASENAME=$(basename "$FILE_PATH" .vue)
      LOWER_FILE_BASENAME=${FILE_BASENAME:l}
      extract_template "VUE_TEMPLATE" | sed "s/{{FILENAME}}/$LOWER_FILE_BASENAME/" > "$FILE_PATH"
      ;;
    *.vue)
      FILE_BASENAME=$(basename "$FILE_PATH" .vue)
      extract_template "VUE_TEMPLATE" | sed "s/{{FILENAME}}/$FILE_BASENAME/" > "$FILE_PATH"
      ;;
    stores/*.ts)
      STORE_NAME=$(basename "$FILE_PATH" .ts)
      # 첫 글자만 대문자로 변환 (zsh parameter expansion + tr 사용)
      CAPITALIZED="$(echo "${STORE_NAME:0:1}" | tr '[:lower:]' '[:upper:]')${STORE_NAME:1}"
      # 전체를 소문자로 변환
      LOWERCASE=$(echo "$STORE_NAME" | tr '[:upper:]' '[:lower:]')
      extract_template "STORE_TEMPLATE" | sed -e "s/{{storeName}}/$LOWERCASE/g" -e "s/{{STORENAME}}/$CAPITALIZED/g" > "$FILE_PATH"
      ;;
    composables/*.ts)
      COMPOSABLE_NAME=$(basename "$FILE_PATH" .ts | sed 's/^use//')
      extract_template "COMPOSABLE_TEMPLATE" | sed "s/{{COMPOSABLENAME}}/$COMPOSABLE_NAME/" > "$FILE_PATH"
      ;;
    middleware/*.global.ts)
      extract_template "MIDDLEWARE_GLOBAL_TEMPLATE" > "$FILE_PATH"
      ;;
    middleware/*.ts)
      extract_template "MIDDLEWARE_TEMPLATE" > "$FILE_PATH"
      ;;
    plugins/*.ts)
      extract_template "PLUGIN_TEMPLATE" > "$FILE_PATH"
      ;;
    utils/*.ts)
      FILE_BASENAME=$(basename "$FILE_PATH" .ts)
      extract_template "UTILITY_TEMPLATE" | sed "s/{{FILENAME}}/$FILE_BASENAME/" > "$FILE_PATH"
      ;;
    assets/css/tailwind.css)
      extract_template "TAILWIND_TEMPLATE" > "$FILE_PATH"
      ;;
    *.env.local)
      extract_template "ENV_LOCAL_TEMPLATE" > "$FILE_PATH"
      ;;
    *.env.development)
      extract_template "ENV_DEVELOPMENT_TEMPLATE" > "$FILE_PATH"
      ;;
    *.env.production)
      extract_template "ENV_PRODUCTION_TEMPLATE" > "$FILE_PATH"
      ;;
    *)
      extract_template "DEFAULT_TEMPLATE" | sed "s/{{FILENAME}}/$FILE_NAME/" > "$FILE_PATH"
      ;;
  esac
done <<< "$FILE_LIST"

# 완료 메시지 출력
echo "✅ Nuxt 프로젝트 파일 생성이 완료되었습니다!"
