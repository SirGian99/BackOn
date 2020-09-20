//
//  RequestViews.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 09/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct RequestView<GenericUser:BaseUser>: View {
    let request: Request
    let helper: GenericUser
    @State var showModal = false
    @State var showLoadingOverlay = false
    
    var body: some View {
        let isExpired = request.isExpired()
        let hasHelper = request.helper?.id != nil
        return Button(action: {self.showModal = true}) {
            ZStack(alignment: .leading) {
                VStack(alignment: .trailing, spacing: 5) {
                    Spacer()
                    Text(request.title)
                        .fontWeight(.medium)
                        .font(.title3)
                        .tint(.black)
                    Text("\(request.date, formatter: customDateFormat)")
                        .tint(.grayLabel)
                    Text(helper.name)
                        .orange()
                        //.foregroundColor(isExpired ? Color(hex: "#f77f00") : Color(.systemOrange))
                    Spacer()
                }
                .padding(.horizontal, 18)
                .frame(width: 265, height: 104, alignment: .trailing)
                .backgroundIf(isExpired, .expiredNeed, .white)
                .overlayIf(.constant(!hasHelper && !isExpired), toOverlay: RoundedRectangle(cornerRadius: 10).stroke(Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)), lineWidth: 3))
                .loadingOverlayIf(.constant(showLoadingOverlay))
                .cornerRadius(10)
                .shadow(color: Color(.systemGray3), radius: 3)
                .offset(x: 40)
                helper.avatar(size: 80)
                    .blackOverlayIf(.constant(showLoadingOverlay), opacity: 0.1)
                    .clipShape(Circle())
                    .shadow(color: Color(.systemGray3), radius: 3)
            }.frame(width: 305, height: 106)
        }
        .opaqueButtonStyle()
        .sheet(isPresented: self.$showModal) { DetailedView(need: request, user: helper, isDiscoverSheet: false) }
        .onReceive(request.objectWillChange) {_ in self.showLoadingOverlay = request.waitingForServerResponse}
    }
}

struct RequestViewOLD<GenericUser:BaseUser>: View {
    let request: Request
    let helper: GenericUser
    @State var showModal = false
    @State var showLoadingOverlay = false
    
    var body: some View {
        let isExpired = request.isExpired()
        let hasHelper = request.helper?.id != nil
        return Button(action: {self.showModal = true}) {
            VStack(spacing: 0) {
                Spacer()
                ZStack(alignment: .bottom) {
                    VStack(spacing: 3) {
                        Text(helper.identity)
                            .fontWeight(.medium)
                            .font(.system(size: 23))
                        Text(request.title)
                            .font(.body)
                        Text("\(request.date, formatter: customDateFormat)")
                            .tint(.grayLabel)
                            .padding(.horizontal, 10)
                            .frame(width: 320, alignment: .trailing)
                    }
                    .tintIf(!hasHelper && !isExpired, .need, .white) //usa l'arancione del BG dei task per il testo delle request non accettate e attive
                    .offset(y: 10)
                    .frame(width: 320, height: 110)
                    .backgroundIf(isExpired, .expiredNeed, hasHelper ? .need : .white)
                    .overlayIf(.constant(!hasHelper && !isExpired), toOverlay: RoundedRectangle(cornerRadius: 10).stroke(Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)), lineWidth: 3))
                    .loadingOverlayIf(.constant(showLoadingOverlay))
                    .cornerRadius(10)
                    .shadow(color: Color(.systemGray3), radius: 3)
                    helper.avatar(size: 75)
                        .blackOverlayIf(.constant(showLoadingOverlay), opacity: 0.1)
                        .clipShape(Circle())
                        .offset(y: -85)
                        .shadow(color: Color(.systemGray3), radius: 3)
                }
            }.frame(height: 160)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$showModal) { DetailedView(need: request, user: helper, isDiscoverSheet: false) }
        .onReceive(request.objectWillChange) {_ in self.showLoadingOverlay = request.waitingForServerResponse}
    }
}

struct RequestRow: View {
    @ObservedObject var cdc = CD.controller

    var body: some View {
        let activeRequests = cdc.activeRequestsController.fetchedObjects ?? []
        let expiredRequests = cdc.expiredRequestsController.fetchedObjects ?? []
        return VStack(spacing: 0) {
            if activeRequests.isEmpty && expiredRequests.isEmpty {
                HStack(spacing: 7) {
                    Spacer()
                    Text("Tap on")
                    Image("AddNeedSymbol").font(.title)
                    Text("to add a request")
                    Spacer()
                }.font(.body).tint(.gray)
            } else {
                NavigationLink(destination: NeedList<Request>()) {
                    HStack {
                        Text("Your requests")
                            .font(.system(.title, design: Font.Design.rounded))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .orange()
                    }.padding(.horizontal, 20)
                }.accentColor(getColor(.orange))
                SizedDivider(height: 5)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(cdc.pendingRequests) { currentReq in
                            RequestView(request: currentReq, helper: NobodyAccepted.instance)
                        }
                        ForEach(activeRequests) { currentReq in
                            if currentReq.helper == nil {
                                RequestView(request: currentReq, helper: NobodyAccepted.instance)
                            } else {
                                RequestView(request: currentReq, helper: currentReq.helper!)
                            }
                        }
                        ForEach(expiredRequests) { currentReq in
                            if currentReq.helper == nil {
                                RequestView(request: currentReq, helper: NobodyAccepted.instance)
                            } else {
                                RequestView(request: currentReq, helper: currentReq.helper!)
                            }
                        }
                    }
                    .padding(.vertical, 10)
//                    .padding(.horizontal, 20)
                }
            }
        }
    }
}