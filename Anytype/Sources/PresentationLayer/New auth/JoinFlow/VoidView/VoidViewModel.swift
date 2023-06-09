import SwiftUI

@MainActor
final class VoidViewModel: ObservableObject {
    
    private weak var output: JoinFlowStepOutput?
    
    init(output: JoinFlowStepOutput?) {
        self.output = output
    }
    
    func onNextButtonTap() {
        output?.onNext()
    }
}