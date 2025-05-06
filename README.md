# make-nuxt-files

Zsh 기반 스크립트를 사용해 `files.list`와 `default.template`을 바탕으로 Nuxt 프로젝트의 기본 파일 구조를 자동 생성하는 유틸리티입니다.

---

## 📌 주요 기능

* `files.list`에 정의된 경로 목록을 읽어와 각 파일을 생성
* 파일 확장자(`.vue`, `.ts`, `.env.*` 등)에 맞는 템플릿 섹션을 `default.template`에서 추출
* `{{FILENAME}}` 플레이스홀더를 실제 파일명으로 치환
* 하위 디렉토리 자동 생성 및 오류 발생 시 상세 메시지 출력

---

## ⚙️ 설치 및 사용 방법

1. **레포지토리 클론**

   ```bash
   git clone https://github.com/<your-username>/make-nuxt-files.git
   cd make-nuxt-files
   ```

2. **스크립트 실행 권한 부여**

   ```bash
   chmod +x setup-nuxt-template.sh
   ```

3. **파일 생성**

   ```bash
   ./setup-nuxt-template.sh
   ```

   * 성공 시:

     ```
     ✅ Nuxt 프로젝트 파일 생성이 완료되었습니다!
     ```
   * 오류 발생 시:

     ```
     ❌ 오류 발생: <command> (라인: <lineno>)
     ```

---

## 📂 레포지토리 구조

```
.
├── README.md
├── setup-nuxt-template.sh   # 메인 스크립트
├── files.list               # 생성할 파일 경로 목록
└── default.template         # 파일 타입별 템플릿 정의
```

### files.list

* 생성할 파일 경로(상대경로)를 한 줄에 하나씩 나열
* 예시:

  ```text
  app.vue
  assets/css/tailwind.css
  components/common/Header.vue
  .env.local
  .env.development
  .env.production
  ```

### default.template

* `#### SECTION_NAME ####` 형식으로 템플릿 섹션을 구분
* 예시:

  ```text
  #### VUE_TEMPLATE ####
  <script setup lang="ts">
  const title = ref('{{FILENAME}}')
  </script>

  <template>
    <div class="{{FILENAME}}-container">…</div>
  </template>

  #### ENV_LOCAL_TEMPLATE ####
  # .env.local 예시
  API_URL=https://api.example.com

  #### DEFAULT_TEMPLATE ####
  // 기본 템플릿 ({{FILENAME}})
  console.log("Hello, {{FILENAME}}!");
  ```

---

## 🔧 커스터마이징

* **files.list**
  원하는 파일 및 디렉토리 구조에 맞춰 자유롭게 수정 가능합니다.

* **default.template**

  1. 새로운 파일 타입이 필요하면 `#### MY_TEMPLATE ####` 섹션 추가
  2. `setup-nuxt-template.sh`의 `case` 블록에 패턴 매칭 로직 확장
  3. 기존 섹션을 수정해 프로젝트 스타일에 맞는 헤더, 주석, 코드 스니펫 등을 반영하세요.

---

## ✨ 팁 & 트릭

* 공통 함수나 주입 코드가 필요할 때 `default.template`에 별도 섹션으로 관리
* `.env` 파일에 민감 정보는 템플릿에 예시만 두고, 실제 값은 `.env.local` 등으로 관리
* 스크립트를 재실행하면 기존 파일이 덮어쓰기되므로 주의

---

## 📄 라이선스

MIT License
자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요。

---