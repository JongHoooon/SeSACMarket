# 새싹마켓 - naver 검색 api 기반 상품 검색 앱 🛒 

- Development Period: 2023.09.08 ~ 2023.09.15
- Role: iOS 전체 개발

<br>

## Screenshot
<p align="center"><img src="https://github.com/JongHoooon/SeSACMarket/assets/98168685/73f4c5e6-2dbd-4cb2-8b35-ad623bf4de3d"></p>

<br>

## Architecture
- MVVM-C
- Clean Architecture

<br>

<p align="center"><img width="884" alt="image" src="https://github.com/JongHoooon/SeSACMarket/assets/98168685/f6141d16-86cf-4660-9ac4-de4f015ba30b"></p>

<p align="center"><img width="884" alt="image" src="https://github.com/JongHoooon/SeSACMarket/assets/98168685/c54a7b48-26d4-4b6c-bb04-4a428087bf29"></p>

<br>

## Tech Stack
- UIKit, URLSession, Async/Await, Compositional Layout
- RxSwift, SnapKit, Realm, Kingfisher

<br>

## Core Feature
- 상품을 검색하고 좋아요 기능을 통해 좋아요 목록에 저장할 수 있습니다.
- 좋아요 목록에서 좋아요한 상품들을 확인하고 검색할 수 있습니다.
- 상품 웹페이지를 조회해 상세 정보를 확인할 수 있습니다.

<br>

## Description
- 상품 검색 화면 
  - naver 쇼핑 api 기반 상품 검색, **pagenation** 처리
- 좋아요 목록
  - **realm database** 기반 좋아요한 상품들 확인, Query API 로 실시간 검색
- 상품 상세 화면
  - **WKWebView**와 **URLRequest**를 활용한 웹뷰 핸들링
- **realm database** 기반 좋아요 상품들 저장, **notification center** 기반 좋아요 상태 동기화
- **URLSession** 기반 **router pattern**, **response logging**, **generic request** 메소드 구현
- **CheckedContinuation** 사용해 Realm 관련 작업 비동기 처리

<br>

## Troubleshooting
- [Coordinator 기반 화면 전환 로직 재사용](https://velog.io/@qnm83/Coordinator-%EA%B8%B0%EB%B0%98-%ED%99%94%EB%A9%B4-%EC%A0%84%ED%99%98%EB%A1%9C%EC%A7%81-%EC%9E%AC%EC%82%AC%EC%9A%A9)
- [Coordinator finish() 로직 재사용 하기](https://velog.io/@qnm83/Coordinator-finish-%EB%A1%9C%EC%A7%81-%EA%B5%AC%EC%A1%B0%ED%99%94-%ED%95%98%EA%B8%B0)
