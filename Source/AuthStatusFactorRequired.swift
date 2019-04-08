/*
 * Copyright (c) 2019, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation

open class OktaAuthStatusFactorRequired : OktaAuthStatus {

    override init(oktaDomain: URL, model: OktaAPISuccessResponse, responseHandler: AuthStatusCustomHandlerProtocol? = nil) {
        super.init(oktaDomain: oktaDomain, model: model, responseHandler: responseHandler)
        statusType = .MFARequired
    }
    
    override init(currentState: OktaAuthStatus, model: OktaAPISuccessResponse) {
        super.init(currentState: currentState, model: model)
        statusType = .MFARequired
    }

    public var availableFactors: [EmbeddedResponse.Factor]? {
        get {
            return model.embedded?.factors
        }
    }

    public func selectFactor(factor: EmbeddedResponse.Factor,
                             onStatusChange: @escaping (_ newStatus: OktaAuthStatus) -> Void,
                             onError: @escaping (_ error: OktaError) -> Void) {
        self.triggerFactor(factor: factor,
                           stateToken: model.stateToken!,
                           answer: nil,
                           passCode: nil,
                           completion: { result in
                            
                            self.handleServerResponse(result,
                                                      onStatusChanged: onStatusChange,
                                                      onError: onError)
        })
    }

    func triggerFactor(factor: EmbeddedResponse.Factor,
                       stateToken: String,
                       answer: String?,
                       passCode: String?,
                       completion: ((OktaAPIRequest.Result) -> Void)? = nil) -> Void {
        if let link = factor.links?.next {
            self.api.verifyFactor(with: link,
                                  stateToken: model.stateToken!,
                                  answer: nil,
                                  passCode: nil,
                                  rememberDevice: nil,
                                  autoPush: nil,
                                  completion: completion)
        } else {
            self.api.verifyFactor(factorId: factor.id!,
                                  stateToken: model.stateToken!,
                                  answer: nil,
                                  passCode: nil,
                                  rememberDevice: nil,
                                  autoPush: nil,
                                  completion: completion)
        }
    }
}
