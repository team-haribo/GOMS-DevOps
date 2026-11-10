# 현재 모니터링 구성

운영 서버의 /home/ubuntu/goms-monitoring/docker-compose.yml과 컨테이너 bind mount를 기준으로 기록했다. 이 디렉터리에는 조사 당시 Git 메타데이터가 없었다.

| 구성 | 실제 설정 | 데이터 보존 |
| --- | --- | --- |
| Prometheus | prometheus.yml에서 15초마다 Backend /actuator/prometheus와 Node Exporter 수집을 선언 | named volume, Compose 명령의 7일·1GB 제한 |
| Grafana | localhost 바인딩, grafana/provisioning/datasources/에 Prometheus·Loki datasource | named volume |
| Loki | loki/loki-config.yml, 파일시스템 저장 | named volume, retention 168시간 |
| Alloy | alloy/config.alloy이 GOMS Nginx access·error·observability 로그를 Loki로 전달하도록 선언 | named volume |
| Node Exporter | 호스트 루트를 읽기 전용 마운트하여 Prometheus의 수집 대상 제공 | 데이터 volume 없음 |

Prometheus가 Backend Docker 네트워크에도 붙기 위해 Monitoring Compose는 외부 네트워크 이름 GOMS_NETWORK를 참조한다. 현재 연결된 네트워크는 goms-backend-v3_default로 확인됐지만 변수 값은 수집하지 않았다. 따라서 이 저장소의 Compose만으로 새 서버에서 바로 실행 가능하다고 단정하지 않는다.

Grafana의 datasource 두 개만 파일 provisioning에서 확인했다. Dashboard·Alert provisioning 파일은 없었고 실제 UI Dashboard와 Alert 목록은 확인하지 못했다. 이 저장소에는 Dashboard JSON이나 Alert 규칙을 임의로 만들지 않았다. Prometheus target의 실제 UP 상태와 Loki/Alloy의 최근 수집 성공 상태도 확인되지 않았다.
