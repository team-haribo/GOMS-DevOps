# 현재 배포 흐름

이 문서는 실행이 검증된 새 절차가 아니라 2026-11-10 서버 스크립트와 각 앱 저장소의 workflow에서 확인한 순서를 기록한다. 이 저장소의 스크립트는 운영 서버에 자동 적용되지 않는다.

## Backend

GOMS-Backend-V3/.github/workflows/deploy.yml은 main push에서 appleboy/ssh-action@v1.2.0으로 서버의 /home/ubuntu/deploy-goms.sh를 호출하도록 선언한다.

현재 스크립트는 /home/ubuntu/GOMS-Backend-V3에서 git fetch origin → git checkout main → git pull origin main → docker compose build app → docker compose up -d --no-deps app → docker image prune -f → docker compose ps 순서로 실행된다. DB와 Redis는 이 명령의 직접적인 교체 대상이 아니다. 컨테이너 restart policy는 always다.

Backend Compose와 Dockerfile은 Backend 저장소에서 추적한다. 앱은 서버의 .env를 env_file로 읽고 Compose는 DB_NAME, DB_USERNAME, DB_PASSWORD, REDIS_PASSWORD, SPRING_PROFILES_ACTIVE, TZ를 참조한다. 변수 값과 별도 주입 절차는 수집하지 않았다.

## Discord Bot

GOMS-Bot-V1/.github/workflows/deploy.yml도 main push에서 같은 SSH Action으로 /home/ubuntu/deploy-goms-bot.sh를 호출하도록 선언한다.

현재 스크립트는 /home/ubuntu/GOMS-Bot-V1에서 git fetch origin → git checkout main → git pull origin main → docker compose down → docker compose up -d --build → docker compose ps 순서로 실행된다. 컨테이너 restart policy는 always다.

서버의 Bot Compose·Dockerfile은 Bot Git 체크아웃에서 미추적이다. Compose가 .env를 참조하며, 코드에는 GOMS_INTERNAL_API_URL, GOMS_INTERNAL_API_SECRET, OUTING_STATE_FILE 등의 변수 참조가 있다. 값은 이 저장소에 없다.

## 검증 및 되돌리기 범위

두 스크립트에 명시적인 서비스 healthcheck, 자동 롤백, 배포 전 데이터 백업 단계는 확인되지 않았다. GitHub Actions의 실제 최근 실행 결과, 배포 실패 시 조치, 복구 절차는 조사하지 않았다. 이 문서의 명령 목록만으로 안전한 재배포나 롤백이 가능하다고 단정하지 않는다.
