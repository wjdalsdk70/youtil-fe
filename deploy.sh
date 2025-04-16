#!/bin/bash
echo "🚀 [프론트엔드(Next.js) 배포 시작] $(date)"

if [ "$1" == "--rollback" ]; then
  if [ -f prev-deploy.txt ]; then
    echo "🔙 롤백 실행"
    git checkout $(cat prev-deploy.txt) || exit 1
  else
    echo "❌ 롤백 실패: prev-deploy.txt 없음"
    exit 1
  fi
else
  echo "📦 최신 코드 Pull"
  git pull origin main || exit 1

  if [ -f last-deploy.txt ]; then
    cp last-deploy.txt prev-deploy.txt
  fi
fi

echo "📦 패키지 설치"
npm install || exit 1

echo "🔧 빌드"
npm run build || exit 1

echo "🛑 기존 Next.js 프로세스 종료"
pkill -f 'next start'

echo "🚀 애플리케이션 실행"
nohup npm run start > ~/next-frontend.log 2>&1 &

if [ "$1" != "--rollback" ]; then
  git rev-parse HEAD > last-deploy.txt
  echo "📝 배포 커밋 기록 저장 완료"
fi

echo "✅ 프론트엔드 배포 완료"