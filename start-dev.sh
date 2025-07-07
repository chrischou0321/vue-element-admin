#!/bin/bash

# Vue Element Admin Dashboard 開發啟動腳本
echo "啟動 Vue Element Admin Dashboard..."

# 檢查 Node.js 版本
echo "檢查 Node.js 版本..."
node --version

# 檢查 npm 版本
echo "檢查 npm 版本..."
npm --version

# 確保依賴已安裝
if [ ! -d "node_modules" ]; then
    echo "安裝依賴..."
    npm install
fi

# 啟動開發服務器
echo "啟動開發服務器..."
npm run dev

# 提供訪問信息
echo "開發服務器已啟動"
echo "本地訪問: http://localhost:9527"
echo "網絡訪問: http://[your-ip]:9527"