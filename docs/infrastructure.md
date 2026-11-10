# 운영 인프라 현황

2026-11-10 읽기 전용 조사 기준이다. 서버는 Ubuntu 22.04, Docker 29.3.0, Compose v5.1.1을 사용했다. 컨테이너 9개 모두 실행 중이었다. 파일을 이 저장소에 보존한 것과 서버에 적용한 것은 별개다.

## 실행 구조

| Compose 프로젝트 | 실제 Compose 경로 | 서비스 | 네트워크 |
| --- | --- | --- | --- |
| goms-backend-v3 | /home/ubuntu/GOMS-Backend-V3/docker-compose.yml | 앱, MariaDB 11.4, Redis 7.4 | goms-backend-v3_default |
| goms-bot-v1 | /home/ubuntu/GOMS-Bot-V1/docker-compose.yml | Discord Bot | goms-bot-v1_goms-bot-network |
| goms-monitoring | /home/ubuntu/goms-monitoring/docker-compose.yml | Prometheus, Grafana, Loki, Alloy, Node Exporter | goms-monitoring_monitoring; Prometheus는 Backend 네트워크에도 연결 |

Nginx는 호스트의 systemd 서비스다. GOMS 사이트 설정은 TLS listener에서 로컬 Backend 127.0.0.1:8080으로 프록시한다. 같은 파일에 80 포트의 정적 파일 서버 블록도 있다. 그 블록의 GOMS 소속 여부는 확인되지 않았다. DB·Redis·Backend·Grafana 호스트 바인딩은 loopback이고 나머지 Monitoring 서비스와 Bot에는 호스트 포트 바인딩이 없다. 외부 방화벽/NAT 정책은 확인되지 않았다.

MariaDB, Redis, Prometheus, Grafana, Loki, Alloy는 각각 Docker named volume을 사용한다. Bot에는 데이터 마운트가 없다. Bot 코드의 자동화 상태 기본 경로는 컨테이너 내부 /app/data/automation-state.json이고 OUTING_STATE_FILE로 달라질 수 있다. 실제 변수 값과 상태의 영속성은 확인되지 않았다.

## 파일 원본과 적용 경로

| 이 저장소 | 운영 서버 원본 | 실제 사용 근거 |
| --- | --- | --- |
| scripts/deploy-goms.sh | /home/ubuntu/deploy-goms.sh | Backend deploy workflow의 호출 경로 |
| scripts/deploy-goms-bot.sh | /home/ubuntu/deploy-goms-bot.sh | Bot deploy workflow의 호출 경로 |
| nginx/sites-enabled/goms | /etc/nginx/sites-enabled/goms | Nginx include 대상, TLS와 Backend proxy |
| nginx/conf.d/goms-observability.conf | /etc/nginx/conf.d/goms-observability.conf | Nginx include 대상, goms_json 로그 포맷 |
| monitoring/docker-compose.yml | /home/ubuntu/goms-monitoring/docker-compose.yml | 실행 중 goms-monitoring Compose Project |
| monitoring/prometheus.yml | /home/ubuntu/goms-monitoring/prometheus.yml | Prometheus 컨테이너 read-only bind mount |
| monitoring/loki/loki-config.yml | /home/ubuntu/goms-monitoring/loki/loki-config.yml | Loki 컨테이너 read-only bind mount |
| monitoring/alloy/config.alloy | /home/ubuntu/goms-monitoring/alloy/config.alloy | Alloy 컨테이너 read-only bind mount |
| monitoring/grafana/provisioning/datasources/*.yml | /home/ubuntu/goms-monitoring/grafana/provisioning/datasources/*.yml | Grafana provisioning read-only bind mount |

위 설정 파일 10개는 조사 당시 서버 파일과 SHA-256이 동일한 바이트로 보존했다. Secret 제거에 따른 파일 차이는 없다. 현재 운영 파일과 이 저장소가 앞으로 자동 동기화되지는 않는다.

두 배포 스크립트는 서버에서 실행 권한이 있으며 Git에서도 실행 비트를 보존한다. Git은 파일의 세부 권한 전체를 보존하지 않으므로 서버의 소유자·그룹·쓰기 권한을 이 저장소만으로 재현할 수는 없다.

## 저장소 경계

Backend의 Dockerfile·Compose·.env.example·workflow는 [Backend 저장소](https://github.com/team-haribo/GOMS-Backend-V3)에서 이미 추적한다. Bot의 Dockerfile·Compose는 서버에서 실제 사용하지만 [Bot 저장소](https://github.com/team-haribo/GOMS-Bot-V1)의 서버 체크아웃에서는 미추적이다. Bot 코드와 빌드 설정의 단일 원본은 Bot 저장소로 정리할 대상이며 이번 저장소에 복사하지 않았다. 두 앱 저장소는 이번 작업에서 변경하지 않았다.

## 저장소 제외 대상

Backend/Bot/Monitoring의 .env, SSH·TLS 개인키와 인증서 원문, Secret, Docker volume, DB dump, Bot 상태 파일, Nginx 로그, 과거 .bak·.swp 파일은 수집하지 않았다. Nginx 설정의 인증서 경로와 Monitoring Compose의 GOMS_NETWORK 변수 참조만 보존했다. 이 변수의 운영 값은 저장하지 않았다.
