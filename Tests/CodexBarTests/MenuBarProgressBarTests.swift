import AppKit
import CodexBarCore
import Testing
@testable import CodexBar

@MainActor
struct MenuBarProgressBarTests {
    @Test
    func `estimated progress bars preserve the accessible estimate marker`() {
        let fixture = MenuBarLayoutRendererTests()
        var data = fixture.data()
        data.quotaIsEstimated = true
        let output = MenuBarLayoutRenderer().render(
            layout: MenuBarLayout(lines: [[.progressBar(window: .session)]]),
            data: data,
            icon: nil,
            options: fixture.options())

        #expect(output.accessibilityLabel == L("%@ %@", L("Session"), "~25%"))
    }

    @Test
    func `automatic balance bars suppress duplicate resets including conditional branches`() {
        let fixture = MenuBarLayoutRendererTests()
        let renderer = MenuBarLayoutRenderer()
        var rule = MenuBarLayoutConditional.makeDefault()
        rule.thenToken = .progressBar(window: .automatic)
        rule.elseToken = rule.thenToken
        let balance = fixture.data(
            provider: .deepseek, automaticText: "¥100.00", automaticBalanceFallback: "¥100.00")
        for token in [MenuBarLayoutToken.progressBar(window: .automatic), .conditional(id: rule.id)] {
            let output = renderer.render(
                layout: MenuBarLayout(lines: [[token, .separatorDot, .resetCountdown]]),
                data: balance,
                icon: nil,
                options: fixture.options(conditionals: [rule]))
            #expect(output.attributedTitle.string == "¥100.00")
        }
        let resetOnly = renderer.render(
            layout: MenuBarLayout(lines: [[.resetCountdown]]),
            data: balance,
            icon: nil,
            options: fixture.options())
        #expect(resetOnly.attributedTitle.string == "¥100.00")
        let dated = renderer.render(
            layout: MenuBarLayout(lines: [[.progressBar(window: .automatic), .resetCountdown]]),
            data: fixture.data(automaticText: "¥100.00"),
            icon: nil,
            options: fixture.options())
        #expect(dated.attributedTitle.string == "¥100.00\u{2009}in 2h")
    }

    @Test
    func `progress bar redraws changed usage and remaining mode in light and dark appearances`() throws {
        let fixture = MenuBarLayoutRendererTests()
        let renderer = MenuBarLayoutRenderer()
        let layout = MenuBarLayout(lines: [[.progressBar(window: .automatic)]])
        for name in [NSAppearance.Name.aqua, .darkAqua] {
            let appearance = try #require(NSAppearance(named: name))
            var result: Result<Void, Error> = .success(())
            appearance.performAsCurrentDrawingAppearance {
                result = Result {
                    @MainActor
                    func image(percent: Double, showUsed: Bool) throws -> Data {
                        let result = renderer.render(
                            layout: layout,
                            data: fixture.data(automaticUsedPercent: percent),
                            icon: nil,
                            options: fixture.options(showUsed: showUsed, appearanceName: name.rawValue))
                        let attachment = try #require(result.attributedTitle.attribute(
                            .attachment, at: 0, effectiveRange: nil) as? NSTextAttachment)
                        return try #require(attachment.image?.tiffRepresentation)
                    }
                    let low = try image(percent: 20, showUsed: true)
                    let high = try image(percent: 80, showUsed: true)
                    #expect(low != high)
                    #expect(try image(percent: 80, showUsed: false) == low)
                    #expect(try image(percent: 20, showUsed: true) == low)
                }
            }
            try result.get()
        }
    }
}
