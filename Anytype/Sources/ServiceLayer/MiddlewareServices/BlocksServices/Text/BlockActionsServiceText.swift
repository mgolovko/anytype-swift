import Foundation
import Combine
import UIKit
import ProtobufMessages
import BlocksModels
import Amplitude


private extension BlockActionsServiceText {
    enum PossibleError: Error {
        case setStyleActionStyleConversionHasFailed
        case setAlignmentActionAlignmentConversionHasFailed
        case splitActionStyleConversionHasFailed
    }
}

final class BlockActionsServiceText: BlockActionsServiceTextProtocol {    

    @discardableResult
    func setText(contextID: String, blockID: String, middlewareString: MiddlewareString) -> AnyPublisher<Void, Error> {        
        return Anytype_Rpc.Block.Set.Text.Text.Service
            .invoke(contextID: contextID, blockID: blockID, text: middlewareString.text, marks: middlewareString.marks, queue: .global())
            .successToVoid()
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextText)
            })
            .subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .eraseToAnyPublisher()
    }
    
    // MARK: SetStyle
    func setStyle(contextID: BlockId, blockID: BlockId, style: Style) -> AnyPublisher<ResponseEvent, Error> {
        let style = BlockTextContentTypeConverter.asMiddleware(style)
        return setStyle(contextID: contextID, blockID: blockID, style: style)
    }

    private func setStyle(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Set.Text.Style.Service.invoke(contextID: contextID, blockID: blockID, style: style).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextStyle,
                                              withEventProperties: [AmplitudeEventsPropertiesKey.blockStyle: String(describing: style)])
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: SetForegroundColor
    func setForegroundColor(contextID: String, blockID: String, color: String) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextID, blockID: blockID, color: color)
            .successToVoid()
            .subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .eraseToAnyPublisher()
    }
    
    // MARK: Split
    func split(contextID: BlockId,
               blockID: BlockId, range: NSRange,
               style: Style,
               mode: Anytype_Rpc.Block.Split.Request.Mode) -> AnyPublisher<SplitSuccess, Error> {
        let style = BlockTextContentTypeConverter.asMiddleware(style)
        let middlewareRange = RangeConverter.asMiddleware(range)

        return split(contextID: contextID, blockID: blockID, range: middlewareRange, style: style, mode: mode)
            .handleEvents(receiveSubscription: { _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockSplit)
        }).eraseToAnyPublisher()
    }

    private func split(contextID: String, blockID: String,
                       range: Anytype_Model_Range,
                       style: Anytype_Model_Block.Content.Text.Style,
                       mode: Anytype_Rpc.Block.Split.Request.Mode) -> AnyPublisher<SplitSuccess, Error> {
        Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode, queue: .global())
            .map(SplitSuccess.init(_:))
            .subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .eraseToAnyPublisher()
    }

    // MARK: Merge
    func merge(contextID: BlockId, firstBlockID: BlockId, secondBlockID: BlockId) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Merge.Service.invoke(
            contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID, queue: .global()
        )    
        .map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
        .receiveOnMain()
        .handleEvents(receiveSubscription: { _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockMerge)
        })
        .eraseToAnyPublisher()
    }
    
    // MARK: Checked
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Set.Text.Checked.Service.invoke(
            contextID: contextId,
            blockID: blockId,
            checked: newValue,
            queue: .global()
        )
        .map(\.event)
        .map(ResponseEvent.init(_:))
        .subscribe(on: DispatchQueue.global())
        .receiveOnMain()
        .handleEvents(receiveSubscription: { _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextChecked)
        })
        .eraseToAnyPublisher()
    }
    
}
