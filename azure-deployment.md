# Azure 部署配置

## 專案概述

Vue Element Admin Dashboard 部署在 Azure 的配置文件。

## 部署方法

### 1. Azure Static Web Apps 部署

```yaml
# .github/workflows/azure-static-web-apps.yml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - master
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - master

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          api_location: ""
          output_location: "dist"
```

### 2. Azure App Service 部署

```yaml
# .github/workflows/azure-webapp.yml
name: Build and deploy Node.js app to Azure Web App

on:
  push:
    branches:
      - master
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Node.js version
        uses: actions/setup-node@v3
        with:
          node-version: '14.x'

      - name: npm install, build, and test
        run: |
          npm install
          npm run build:prod --if-present

      - name: Upload artifact for deployment job
        uses: actions/upload-artifact@v3
        with:
          name: node-app
          path: dist/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'Production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
      - name: Download artifact from build job
        uses: actions/download-artifact@v3
        with:
          name: node-app

      - name: 'Deploy to Azure Web App'
        id: deploy-to-webapp
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'vue-element-admin-dashboard'
          slot-name: 'Production'
          publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
          package: .
```

### 3. Azure Container Instances 部署

```dockerfile
# Dockerfile
FROM node:14-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build:prod

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```conf
# nginx.conf
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files $uri $uri/ /index.html;
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
```

## 環境變數設定

```bash
# 本地開發環境
NODE_ENV=development
BASE_URL=/

# 生產環境
NODE_ENV=production
BASE_URL=https://your-domain.azurewebsites.net/
```

## 部署腳本

```bash
#!/bin/bash
# deploy.sh

echo "開始部署到 Azure..."

# 建置專案
npm run build:prod

# 使用 Azure CLI 部署
az webapp up --name vue-element-admin-dashboard --resource-group your-resource-group --location "East Asia"

echo "部署完成！"
```

## 監控和日誌

- 使用 Azure Application Insights 監控應用程式效能
- 配置 Azure Monitor 收集日誌
- 設定警報規則監控異常狀況

## 費用估算

- Static Web Apps: 免費層支援基本功能
- App Service: 依據使用量計費
- Container Instances: 按容器運行時間計費

## 注意事項

1. 確保 Azure 訂閱已啟用相關服務
2. 設定正確的 CORS 政策
3. 配置 SSL 憑證
4. 定期更新依賴套件
5. 實施 CI/CD 自動化部署