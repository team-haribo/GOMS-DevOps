# 운영 확인과 복구 범위

아래는 현재 서비스 상태를 읽기 전용으로 확인할 때 사용할 수 있는 명령이다. 실행 전 접속 대상과 권한을 확인한다. 서버 설정·데이터를 바꾸는 조치는 이 문서에 포함하지 않는다.

```sh
docker ps --format '{{.Names}} {{.Status}}'
docker compose ls --all
systemctl status nginx --no-pager
ss -ltn
```

Compose 프로젝트의 실제 파일 경로는 [인프라 현황](infrastructure.md)에 있다. Backend, Bot, Monitoring의 현재 컨테이너 재시작 정책은 각각 always, always, unless-stopped다. docker·nginx·cron·ssh 서비스는 조사 당시 enabled 및 running이었다. 서버 재부팅으로 복구되는지 실험하지 않았다.

MariaDB와 Redis는 Docker named volume을 사용하며 Redis는 AOF appendonly 설정이다. 확인한 프로젝트 경로와 /var/backups의 제한된 범위에서 GOMS DB dump·복구 스크립트를 찾지 못했다. 다른 위치나 외부 백업 여부, 백업 주기, 복구 성공 이력은 확인되지 않았다. volume 존재만으로 서버 유실 후 복구가 가능하다고 판단할 수 없다.

Bot 자동화 상태의 실제 저장 경로와 영속성, Grafana UI Dashboard·Alert의 내보내기 여부, 인증서 재발급·갱신 후 적용 절차, Secret 재주입 절차도 확인되지 않았다. root crontab은 비대화형 읽기 권한이 없어 조사하지 못했다. 이 항목이 확인되기 전에는 이 저장소를 완전한 재구축 수단으로 취급하지 않는다.
