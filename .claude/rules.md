# Peaktime — Claude Code Rules

## 언어 및 플랫폼
- Swift 5.9+, iOS 17.0+, TCA(The Composable Architecture) 1.25 기반으로 작성한다.

## 아키텍처
- UseCase 레이어는 존재하지 않는다. Reducer가 도메인 로직을 직접 담당한다.
- 새 기능은 반드시 Feature Reducer → Domain Repository 인터페이스 → Data liveValue 순서로 구현한다.
- Reducer의 `body`에서 직접 `@Dependency`를 프로퍼티로 선언한다. 클로저 외부에서 resolve하지 않는다.
- DTO → Entity 매핑은 Data 레이어 RepositoryImpl 파일 안에 `extension`으로 `toDomain()`을 구현한다.
- 모든 Repository 인터페이스 클로저와 `@DependencyClient` 클로저는 `@Sendable`을 준수한다.

## Reducer 간 통신
- 형제 Reducer 간 직접 통신은 금지한다. 반드시 부모를 경유한다.
- Parent → Child: `.send(.child(.action))` 또는 `state.child.x = y`로 직접 수정.
- Child → Parent: 자식에 `delegate` Action 케이스를 두고 부모가 수신한다.
- Sibling: 한 쪽의 `delegate`를 부모가 받아 `.send(.other(.action))`으로 전달한다.

## 네비게이션
- Stack 기반 네비게이션은 `StackState` + `@Reducer(state: .equatable)` 조합을 사용한다.
- Sheet / FullScreen은 `@Presents` + `PresentationState` / `PresentationAction`을 사용한다.
- Alert / Dialog는 `AlertState`, `ConfirmationDialogState`를 Action 안에 선언한다.
- 네비게이션 상태는 항상 부모 Reducer가 소유한다. 자식의 dismiss는 `delegate` 패턴으로 부모에 위임한다.

## 의존성 주입 (DI)
- 의존성은 반드시 `@DependencyClient` (struct-of-closures) 패턴으로 정의한다.
- Protocol + Mock 방식은 사용하지 않는다.
- `liveValue`는 Data 레이어에서 `@retroactive DependencyKey`로 주입한다.
- `testValue`의 미호출 클로저는 `XCTFail`이 발생하도록 설계한다.

## 코드 스타일
- 한 줄은 120자를 넘지 않는다.
- TODO/FIXME 작성 시 담당자를 명시한다. 예: `// TODO: 내용 - @이름`
- 4-space indent를 사용한다. `redundantSelf`는 허용한다.

## 네트워킹
- 에러는 반드시 `AFError` → `NetworkError` → `DomainError` 3단계로 매핑한다.
- `any Encodable` 파라미터는 `AnyEncodable`로 래핑한다.
- 응답 Body가 있으면 `requestData`, 없으면(204) `requestEmpty`를 사용한다.
- Repository에서 `requestData`를 직접 호출하지 않는다. `NetworkClient`의 제네릭 편의 메서드 `request<T: Decodable>(_:)`을 사용하고, 디코딩은 `NetworkClient` 내부에서 처리된다.
- JSON 디코딩 전략은 `convertFromSnakeCase`를 기본으로 하고, 예외 필드만 `CodingKeys`를 정의한다.
- API Endpoint는 도메인별 `enum` + `APIEndpoint` 프로토콜 조합으로 정의한다.

## 테스트
- 테스트 프레임워크는 Swift Testing(`@Test`, `#expect`)을 사용한다. XCTest는 사용하지 않는다.
- 테스트 함수명은 한글로 작성한다. 예: `func 로그인_실패시_다이얼로그_표출()`
- Given / When / Then 구조를 반드시 주석으로 명시한다.
- 핵심 유저 동작 위주로만 작성하고, 사소한 유틸 함수는 테스트하지 않는다.
- 주 테스트 대상은 Reducer이며, 필요 시 Repository와 DataSource도 포함한다.
