# Picktime - CLAUDE.md

Claude Code(claude.ai/code)가 이 레포지토리에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

- **App:** Peaktime (Depromeet 18th)
- **Architecture:** Clean Architecture + TCA (iOS 17.0+)
- **Stack:** Tuist(1.25), Alamofire, swift-dependencies

## 개발 환경 설정

### 자주 쓰는 명령어

```bash
make generate    # Tuist 설치 후 .xcworkspace 생성
make clean       # 생성된 xcodeproj, 파생 데이터 정리
make reset       # Tuist 클린 + Package.resolved 삭제 + 생성 파일 전체 정리
```

## 모듈 구조

```
Projects/
├── App/           # 진입점 (PeaktimeApp)
├── Presentation/  # UI 레이어 (Demo 앱 포함)
├── Domain/        # 비즈니스 로직
├── Data/          # 데이터 레이어 (Alamofire 5.11.1)
├── DesignSystem/  # 공용 UI 컴포넌트 & 리소스 (Demo 앱 포함)
└── Core/          # 공용 유틸리티
```

## 핵심 설계 원칙 (Architecture Rules)

### 1. 의존성 관리 (DI)
- **Pattern:** `@DependencyClient` (struct-of-closures) 필수. Protocol-Mock 방식 금지.
- **Test:** `testValue`에서 미호출 클로저 발생 시 `XCTFail` 동작하도록 설계.
- **Resolution:** `@Dependency` 호출은 반드시 **클로저 내부**에서 수행 (Context 유지).
- **Linking:** Domain(인터페이스) ↔ Data(실제 구현) 분리. `@retroactive DependencyKey`로 주입.

### 2. 네트워킹 (Alamofire)
- **Error:** `AFError` → `NetworkError` → `DomainError` 3단계 매핑 필수.
- **Encoding:** `any Encodable`은 `AnyEncodable` 타입 이레이저로 래핑.
- **Response:** Body 유무에 따라 `requestData` / `requestEmpty`(204 대응) 분리 사용.
- **SnakeCase:** `convertFromSnakeCase` 전략 기본 채택. 특이 케이스만 `CodingKeys` 허용.
- **호출 방식:** Repository에서 `requestData`를 직접 호출하지 않는다. `NetworkClient`의 제네릭 편의 메서드 `request<T: Decodable>(_:)`을 사용한다. 디코딩은 `NetworkClient` 내부 extension에서 처리된다.

```swift
// O — 올바른 사용
let dtos: [ExampleItemResponseDTO] = try await client.request(ExampleEndpoint.fetchItems)

// X — requestData를 직접 호출하지 않음
let data = try await client.requestData(ExampleEndpoint.fetchItems)
```

### 3. 모듈 설계 및 도메인
- **TCA:** `UseCase`는 생략하고 `Reducer`가 역할 수행. 
- **Domain:** `Entity`, `Repository 인터페이스`, `DomainError`를 포함하는 **공유 계약 레이어**로 유지.
- **Concurrency:** 모든 인터페이스 및 클로저는 `@Sendable` 준수.
- **Endpoint:** 도메인별 `enum` + `APIEndpoint` 프로토콜 조합으로 관리.

### 4. 레이어별 역할 정리
 
#### Data 레이어
- **Repository:** `liveValue` 구현체 제공
- **NetworkClient:** 전역 단일 객체로 관리
- **DTO:** 각 도메인별 Request/Response DTO 정의
#### Domain 레이어
- **Repository:** `@DependencyClient` 패턴으로 구조체 정의
- **Entity:** 도메인 타입 정의
- **DTO → Entity 매핑:** Data 레이어의 RepositoryImpl 파일 안에 `extension`으로 `toDomain()` 구현
#### Presentation 레이어
- **Reducer(Feature):** 유저 인터랙션 처리 및 도메인 로직 담당

## Reducer 간 통신 패턴

형제 Reducer 끼리는 직접 통신 불가. 반드시 아래 3가지 패턴 중 하나를 따른다.

### Pattern 1 — Parent → Child
부모가 자식에게 액션을 전달하거나 자식 State를 직접 수정.

```swift
case .resetTapped:
    return .send(.child(.reset))          // 자식 액션 전달

case .doubleTapped:
    state.child.count *= 2                // 자식 State 직접 수정
    return .none
```

### Pattern 2 — Child → Parent (Delegate)
자식은 `delegate` Action 케이스를 정의하고, 부모가 이를 수신.

```swift
// Child
enum Action {
    case delegate(Delegate)
    enum Delegate { case submitted(String) }
}

// Parent
case let .child(.delegate(.submitted(text))):
    state.lastSubmitted = text
    return .none
```

### Pattern 3 — Sibling
형제끼리 직접 소통 금지. 부모가 한 쪽의 delegate를 받아 다른 쪽에 전달.

```swift
case let .sender(.delegate(.messageSend(message))):
    return .send(.receiver(.receive(message)))
```

## 네비게이션

- **Stack 기반:** `NavigationStack`과 TCA의 `@Reducer(state: .equatable)` + `StackState` 조합 사용.
- **Sheet / FullScreen:** `@Presents` + `PresentationState` / `PresentationAction` 사용.
- **Alert / Dialog:** `AlertState`, `ConfirmationDialogState`를 Action 안에 선언.
- 네비게이션 상태는 항상 부모 Reducer가 소유. 자식이 자신의 dismiss를 직접 트리거할 때는 `delegate` 패턴 경유.

## 코드 스타일 규칙
- **Line Length:** 120자 권장.
- **Safety:** `force_unwrapping` 금지, `fatalError` 대신 `assertionFailure`.
- **Naming:** TODO/FIXME 작성 시 담당자 명시 (`// TODO: 내용 - @이름`).
- **Formatting:** 4-space indent, `redundantSelf` 허용.

## 테스트 전략
 
### 기본 방침
- **행동 기반 테스트** 작성 (과도한 테스트는 지양)
- **핵심 유저 동작**에 대해서만 작성하고, PR에서 팀원들과 공유
- **테스트 라이브러리:** Swift Testing 사용
### 테스트 대상
- **주 대상:** Reducer
- **필요 시:** Repository, DataSource
### 테스트 템플릿
 
테스트 케이스 명은 **한글**로 작성
 
```swift
func 로그인_실패시_다이얼로그_표출() {
    // Given
    let sut = reducer
 
    // When
    sut.send(.someAction)
 
    // Then
    #expect(sut.state.title == "hello world")
}
```
