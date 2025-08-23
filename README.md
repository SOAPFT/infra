# SOAPFT Infra (Terraform)

SOAPFT 서비스의 AWS 인프라를 Terraform으로 정의한 코드입니다.

---

## Diagram

![image](https://nullisdefined.s3.ap-northeast-2.amazonaws.com/images/18d52b95cbd05768a72325cdd36203cd.png)

## 구성 개요

- **Region**: ap-northeast-2 (서울)
- **Network**: VPC (10.0.0.0/16), Public Subnet(ALB), Private Subnet(ECS, RDS)
- **주요 서비스**:
	- **ECS (Fargate)**: NestJS 애플리케이션 컨테이너 실행
	- **RDS (PostgreSQL)**: 데이터베이스
	- **S3 + CloudFront**: 정적 파일(이미지) 저장, CDN 배포
	- **ECR**: 컨테이너 이미지 저장소
	- **ALB**: HTTPS 트래픽 라우팅
	- **ACM + Route53**: 인증서 및 DNS 관리

---

## 트래픽 주요 흐름

1. **사용자 요청**: Users → Route 53 → Internet Gateway → Application Load Balancer
2. **컨테이너 처리**: ALB → ECS Service → EC2 Instances (Auto Scaling)
3. **데이터 저장**: EC2 Instances → RDS PostgreSQL
4. **파일(이미지) 업로드**: Users → CloudFront CDN → S3 Bucket
5. **AWS 서비스 접근**: EC2 Instances → VPC Endpoints → AWS Services (ECR, CloudWatch, Secrets Manager)

---

## 디렉터리 구조

```
infra/
├─ environments/     # 환경별 변수(tfvars)
├─ modules/          # VPC, ECS, RDS, ALB, S3, ECR 등 모듈화 코드
├─ main.tf
├─ variables.tf
└─ outputs.tf
```
