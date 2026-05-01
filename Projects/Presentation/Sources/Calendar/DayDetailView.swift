import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct DayDetailView: View {
    @Bindable var store: StoreOf<DayDetailFeature>

    public init(store: StoreOf<DayDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            miniCalendarSection // 상단 흰색 카드 - 한 주 미니 캘린더

            Divider()
                .foregroundStyle(Color.gray100)
                .padding(.bottom, 16)

            missionCardSection // 미션 카드 스택

            Spacer()

            actionButtons
                .padding(.horizontal, 17)
                .padding(.bottom, 16)
        }
        .background(Color.gray50)
        .onAppear { store.send(.onAppear) } // 화면 뜰 때 해당 날짜 미션 불러오기
    }

    // MARK: - Mini Calendar

    private var miniCalendarSection: some View {
        VStack(spacing: 12) {
            // "2026년 4월" 제목 + < > 버튼
            CalendarHeaderView(
                title: store.selectedDate.yearMonthString,
                onPrevious: { store.send(.previousWeekTap) },
                onNext: { store.send(.nextWeekTap) }
            )

            // 월 화 수 목 금 토 일
            WeekdayLabelRow()

            // 선택된 날짜가 포함된 주 7일을 가로로 나열
            HStack(spacing: 0) {
                ForEach(store.weekDays, id: \.self) { date in
                    // 날짜 → DateComponents 키로 변환해서 기록 딕셔너리에서 꺼냄
                    let key = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    let record = store.weekRecords[key]
                    // 현재 선택된 날짜인지 판단 (선택된 날짜에 어두운 배경 표시)
                    let isSelected = Calendar.current.isDate(store.selectedDate, inSameDayAs: date)

                    DayCell(
                        date: date,
                        record: record,
                        isSelected: isSelected,
                        onTap: nil // 미니 캘린더에서는 날짜 탭 비활성화
                    )
                    .frame(maxWidth: .infinity) // 7칸이 가로 공간을 균등하게 차지
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(Color.monoWhite)
    }

    // MARK: - Mission Card Stack

    private var missionCardSection: some View {
        Group {
            if store.completions.isEmpty {
                Color.clear // 카드 없으면 빈 공간
            } else {
                CardStackView(
                    cards: store.completions,
                    currentIndex: store.currentCardIndex, // 현재 보여줄 카드 번호
                    onSwipeUp: { store.send(.cardSwipe) } // 스와이프 완료 시 다음 카드로
                )
                .padding(.horizontal, 17)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 13) {
            Button { store.send(.saveImageTap) } label: {
                Text("이미지 저장")
                    .font(.body1, \.medium)
                    .foregroundStyle(Color.gray50)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(Color.gray800)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button { store.send(.saveLinkTap) } label: {
                Text("링크 저장")
                    .font(.body1, \.medium)
                    .foregroundStyle(Color.gray50)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(Color.gray800)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

// MARK: - CardStackView

struct CardStackView: View {
    let cards: [MissionCard]
    let currentIndex: Int
    let onSwipeUp: () -> Void

    @State private var dragOffset: CGFloat = 0 // 드래그 중 카드가 얼마나 이동했는지

    private let maxVisible = 3 // 한 번에 최대 3장까지 보임

    /// 현재 보여줄 카드 인덱스 목록 (뒤 카드부터 ZStack에 추가해야 앞 카드가 위에 그려짐)
    /// 순환 구조라 마지막 카드 이후엔 첫 카드로 돌아옴
    private var visibleIndices: [Int] {
        let count = cards.count
        guard !isEmpty else { return [] }
        let visible = min(maxVisible, count)
        // (0..<visible).reversed() → 뒤 카드(position=2)부터, 앞 카드(position=0)가 마지막에 추가
        return (0 ..< visible).reversed().map { (currentIndex + $0) % count }
    }

    var body: some View {
        ZStack {
            ForEach(visibleIndices, id: \.self) { cardIndex in
                // 순환 인덱스라 단순 뺄셈 대신 모듈로로 position 계산
                // 예: currentIndex=3, cardIndex=0, count=4 → position = (0-3+4)%4 = 1
                let position = (cardIndex - currentIndex + cards.count) % cards.count
                let isTop = position == 0

                MissionCardView(card: cards[cardIndex])
                    // 뒤 카드일수록 10%씩 작아짐
                    .scaleEffect(1.0 - CGFloat(position) * 0.1)
                    // 맨 앞 카드: 드래그한 만큼 이동 / 뒤 카드: 위로 37pt씩 올라가서 앞 카드 위에 살짝 보임
                    .offset(y: isTop ? dragOffset : -CGFloat(position) * 37)
                    // 뒤 카드일수록 흐리게 (0.8 → 0.6)
                    .opacity(position == 0 ? 1.0 : position == 1 ? 0.8 : 0.6)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // 위로 드래그할 때만 반응 (아래로 당기면 무시)
                                guard isTop, value.translation.height < 0 else { return }
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                guard isTop else { return }
                                // 80pt 이상 올리면 → 카드 날리기 (순환이라 항상 다음 카드 있음)
                                if value.translation.height < -80 {
                                    // 카드를 화면 위로 날려버림
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        dragOffset = -700
                                    }
                                    // 날아가는 애니메이션 끝난 뒤 다음 카드로 전환
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            dragOffset = 0
                                            onSwipeUp() // store에 알려서 currentCardIndex 증가
                                        }
                                    }
                                } else {
                                    // 80pt 안 됐으면 원래 자리로 튕겨 돌아옴
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 422)
        // 뒤 카드 2장(27pt × 2 = 54pt)이 앞 카드 위로 삐져나올 공간 확보
        .padding(.top, CGFloat(maxVisible - 1) * 27)
    }
}

// MARK: - MissionCardView

struct MissionCardView: View {
    let card: MissionCard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.missionType)
                .font(.caption1, \.semiBold)
                .foregroundStyle(Color.monoWhite.opacity(0.7))
                .padding(.top, 24)
                .padding(.horizontal, 20)

            Spacer().frame(height: 8)

            Text(card.memo)
                .font(.body2, \.regular)
                .foregroundStyle(Color.monoWhite)
                .padding(.horizontal, 20)

            Spacer()

            AsyncImage(url: card.imageURL) { phase in
                if case let .success(image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .padding(4) // 이미지 바깥 흰색 여백
                        .background(Color.monoWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: 44))
    }
}

// MARK: - Helpers

private extension Date {
    var yearMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: self)
    }
}
