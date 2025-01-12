//
//  TaskViews.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 06/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.colorScheme) var colorScheme
    let task: Task
    let needer: User
    @State var showModal = false
    @State var showLoadingOverlay = false

    var body: some View {
        Button(action: {self.showModal.toggle()}) {
            ZStack(alignment: .bottom) {
                task.matchingSnap(colorScheme: colorScheme)
                Group {
                    ZStack(alignment: .bottom) {
                        Image("cAnnotation").resizable().scaledToFit().orange()
                        needer.avatar(size: 60).offset(y: -15.5)
                    }.frame(width: 66)
                    Text(needer.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .orange()
                        .background(Rectangle().cornerRadius(13).tint(.white).shadow(radius: 5).scaleEffect(1.3))
                        .offset(y: 20)
                }.offset(y: -170)
                VStack(spacing: 5) {
                    Text(task.title)
                        .fontWeight(.medium)
                        .font(.title3)
                        .tint(.black)
                    Text("\(task.date, formatter: customDateFormat)")
                        .tint(.grayLabel)
                }
                .frame(width: 305, height: 75)
                .backgroundIf(task.isExpired(), .expiredNeed, .white)
                .cornerRadius(10)
            }
        }
        .customButtonStyle()
        .frame(width: 305, height: 350)
        .loadingOverlayIf(.constant(showLoadingOverlay))
        .cornerRadius(10)
        .shadow(color: Color(.systemGray3), radius: 3)
        .sheet(isPresented: self.$showModal) { DetailedView(need: task, user: needer, isDiscoverSheet: false) }
        .onReceive(task.objectWillChange) {_ in self.showLoadingOverlay = task.waitingForServerResponse}
    }
}

struct TaskRow: View {
    @ObservedObject var cdc = CD.controller
    
    var body: some View {
        let activeTasks = cdc.activeTasksController.fetchedObjects ?? []
        let expiredTasks = cdc.expiredTasksController.fetchedObjects ?? []
        return VStack(spacing: 0) {
            if activeTasks.isEmpty && expiredTasks.isEmpty {
                SizedDivider(height: 50)
                Image(systemName: "zzz")
                    .resizable()
                    .frame(width: 140, height: 170)
                    .imageScale(.large)
                    .font(.largeTitle)
                    .tint(.gray)
                SizedDivider(height: 40)
                Text("It seems that you don't have anyone to help").tint(.gray)
                SizedDivider(height: 10)
                HStack(spacing: 7) {
                    Spacer()
                    Text("Tap on")
                    Image("DiscoverSymbol").imageScale(.large).font(.title)
                    Text("to find who needs you")
                    Spacer()
                }
                .font(.body)
                .tint(.gray)
                SizedDivider(height: 10)
            } else {
                NavigationLink(destination: NeedList<Task>()) {
                    HStack {
                        Text("Your tasks")
                            .font(.system(.title, design: .rounded))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .orange()
                    }.padding(.horizontal, 20)
                }.accentColor(getColor(.orange))
                SizedDivider(height: 5)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(activeTasks, id: \.id) { currentTask in
                            TaskView(task: currentTask, needer: currentTask.needer)
                        }
                        ForEach(expiredTasks, id: \.id) { currentTask in
                            TaskView(task: currentTask, needer: currentTask.needer)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        let needer = User(entity: User.entity(), insertInto: nil).populate(email: "email", id: "iduser", name: "Name", surname: "Surname", phoneNumber: nil, lastModified: Date())
        let task = Task(entity: Task.entity(), insertInto: nil).populate(id: "id", needer: needer, title: "Title", latitude: 12, longitude: 12, date: Date().advanced(by: 500), lastModified: Date())
        TaskView(task: task, needer: needer)
    }
}
