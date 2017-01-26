//
//  DailyTask.swift
//  LEDA
//
//  Created by Mengying Feng on 13/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import Foundation

//class UserAnalytic: NSObject, NSCoding {
//    
//    var daysInARow: String
//    var tasksCompleted: String
//    var resilienceTasksCompleted: String
//    var negotiationTasksCompleted: String
//    var growthMindsetTasksCompleted: String
//    
//    init(daysInARow: String, tasksCompleted: String, resilienceTasksCompleted: String, negotiationTasksCompleted: String, growthMindsetTasksCompleted: String) {
//        self.daysInARow = daysInARow
//        self.tasksCompleted = tasksCompleted
//        self.resilienceTasksCompleted = resilienceTasksCompleted
//        self.negotiationTasksCompleted = negotiationTasksCompleted
//        self.growthMindsetTasksCompleted = growthMindsetTasksCompleted
//    }
//    
//    required convenience init(coder aDecoder: NSCoder) {
//        let daysInARow = aDecoder.decodeObject(forKey: "UserAnalyticsDaysInARow") as? String ?? ""
//        let tasksCompleted = aDecoder.decodeObject(forKey: "UserAnalyticsTasksCompleted") as? String ?? ""
//        let resilienceTasksCompleted = aDecoder.decodeObject(forKey: "UserAnalyticsResilienceTasksCompleted") as? String ?? ""
//        let negotiationTasksCompleted = aDecoder.decodeObject(forKey: "UserAnalyticsNegotiationTasksCompleted") as? String ?? ""
//        let growthMindsetTasksCompleted = aDecoder.decodeObject(forKey: "UserAnalyticsGrowthMindsetTasksCompleted") as? String ?? ""
//        self.init(daysInARow: daysInARow, tasksCompleted: tasksCompleted, resilienceTasksCompleted: resilienceTasksCompleted, negotiationTasksCompleted: negotiationTasksCompleted, growthMindsetTasksCompleted: growthMindsetTasksCompleted)
//    }
//    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(daysInARow, forKey: "UserAnalyticsDaysInARow")
//        aCoder.encode(tasksCompleted, forKey: "UserAnalyticsTasksCompleted")
//        aCoder.encode(resilienceTasksCompleted, forKey: "UserAnalyticsResilienceTasksCompleted")
//        aCoder.encode(negotiationTasksCompleted, forKey: "UserAnalyticsNegotiationTasksCompleted")
//        aCoder.encode(growthMindsetTasksCompleted, forKey: "UserAnalyticsGrowthMindsetTasksCompleted")
//    }
//}

//class UserTools: NSObject, NSCoding {
//    
//    var isMakingMeaningUnlocked: Bool
//    var isComplexEmotionsUnlocked: Bool
//    var isBreathingUnlocked: Bool
//    
//    init(isMakingMeaningUnlocked: Bool, isComplexEmotionsUnlocked: Bool, isBreathingUnlocked: Bool) {
//        self.isMakingMeaningUnlocked = isMakingMeaningUnlocked
//        self.isComplexEmotionsUnlocked = isComplexEmotionsUnlocked
//        self.isBreathingUnlocked = isBreathingUnlocked
//    }
//    
//    required convenience init(coder aDecoder: NSCoder) {
//        let isMakingMeaningUnlocked = aDecoder.decodeBool(forKey: "UserToolsIsMakingMeaningUnlocked")
//        let isComplexEmotionsUnlocked = aDecoder.decodeBool(forKey: "UserToolsIsComplexEmotionsUnlocked")
//        let isBreathingUnlocked = aDecoder.decodeBool(forKey: "UserToolsIsBreathingUnlocked")
//        self.init(isMakingMeaningUnlocked: isMakingMeaningUnlocked, isComplexEmotionsUnlocked: isComplexEmotionsUnlocked, isBreathingUnlocked: isBreathingUnlocked)
//    }
//    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(isMakingMeaningUnlocked, forKey: "UserToolsIsMakingMeaningUnlocked")
//        aCoder.encode(isComplexEmotionsUnlocked, forKey: "UserToolsIsComplexEmotionsUnlocked")
//        aCoder.encode(isBreathingUnlocked, forKey: "UserToolsIsBreathingUnlocked")
//    }
//}

class Task: NSObject, NSCoding {
    
    var taskDay: String
    var sort: String
    var taskCategory: String
    var taskDurationSeconds: String
    var taskSubcategory: String
    var taskTitle: String
    var taskType: String
    
    // video
    var videoUrl: String
    // quiz
    var answers: [[String: String]]
    var graphImage: String
    var max: String
    var mean: String
    var min: String
    var questions: [String]
    var resultTextIntro: String
    var resultTextSectionResult: [[String: String]]
    var standardDeviation: String
    // checkoff
    var items: [String]
    
    init(taskDay: String, sort: String, taskCategory: String, taskDurationSeconds: String, taskSubcategory: String, taskTitle: String, taskType: String, videoUrl: String, answers: [[String: String]], graphImage: String, max: String, mean: String, min: String, questions: [String], resultTextIntro: String, resultTextSectionResult: [[String: String]], standardDeviation: String, items: [String]) {
        self.taskDay = taskDay
        self.sort = sort
        self.taskCategory = taskCategory
        self.taskDurationSeconds = taskDurationSeconds
        self.taskSubcategory = taskSubcategory
        self.taskTitle = taskTitle
        self.taskType = taskType
        self.videoUrl = videoUrl
        self.answers = answers
        self.graphImage = graphImage
        self.max = max
        self.mean = mean
        self.min = min
        self.questions = questions
        self.resultTextIntro = resultTextIntro
        self.resultTextSectionResult = resultTextSectionResult
        self.standardDeviation = standardDeviation
        self.items = items
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.taskDay = aDecoder.decodeObject(forKey: "TaskTaskDay") as? String ?? ""
        self.sort = aDecoder.decodeObject(forKey: "TaskSort") as? String ?? ""
        self.taskCategory = aDecoder.decodeObject(forKey: "TaskTaskCategory") as? String ?? ""
        self.taskDurationSeconds = aDecoder.decodeObject(forKey: "TaskTaskDurationSeconds") as? String ?? ""
        self.taskSubcategory = aDecoder.decodeObject(forKey: "TaskSubcategory") as? String ?? ""
        self.taskTitle = aDecoder.decodeObject(forKey: "TaskTaskTitle") as? String ?? ""
        self.taskType = aDecoder.decodeObject(forKey: "TaskTaskType") as? String ?? ""
        self.videoUrl = aDecoder.decodeObject(forKey: "TaskVideoUrl") as? String ?? ""
        self.answers = aDecoder.decodeObject(forKey: "TaskAnswers") as? [[String:String]] ?? []
        self.graphImage = aDecoder.decodeObject(forKey: "TaskGraphImage") as? String ?? ""
        self.max = aDecoder.decodeObject(forKey: "TaskMax") as? String ?? ""
        self.mean = aDecoder.decodeObject(forKey: "TaskMean") as? String ?? ""
        self.min = aDecoder.decodeObject(forKey: "TaskMin") as? String ?? ""
        self.questions = aDecoder.decodeObject(forKey: "TaskQuestions") as? [String] ?? []
        self.resultTextIntro = aDecoder.decodeObject(forKey: "TaskResultTextIntro") as? String ?? ""
        self.resultTextSectionResult = aDecoder.decodeObject(forKey: "TaskResultTextSectionResult") as? [[String: String]] ?? []
        self.standardDeviation = aDecoder.decodeObject(forKey: "TaskStandardDeviation") as? String ?? ""
        self.items = aDecoder.decodeObject(forKey: "TaskItems") as? [String] ?? []
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskDay, forKey: "TaskTaskDay")
        aCoder.encode(sort, forKey: "TaskSort")
        aCoder.encode(taskCategory, forKey: "TaskTaskCategory")
        aCoder.encode(taskDurationSeconds, forKey: "TaskTaskDurationSeconds")
        aCoder.encode(taskSubcategory, forKey: "TaskSubcategory")
        aCoder.encode(taskTitle, forKey: "TaskTaskTitle")
        aCoder.encode(taskType, forKey: "TaskTaskType")
        aCoder.encode(videoUrl, forKey: "TaskVideoUrl")
        aCoder.encode(answers, forKey: "TaskAnswers")
        aCoder.encode(graphImage, forKey: "TaskGraphImage")
        aCoder.encode(max, forKey: "TaskMax")
        aCoder.encode(mean, forKey: "TaskMean")
        aCoder.encode(min, forKey: "TaskMin")
        aCoder.encode(questions, forKey: "TaskQuestions")
        aCoder.encode(resultTextIntro, forKey: "TaskResultTextIntro")
        aCoder.encode(resultTextSectionResult, forKey: "TaskResultTextSectionResult")
        aCoder.encode(standardDeviation, forKey: "TaskStandardDeviation")
        aCoder.encode(items, forKey: "TaskItems")
    }
}

class UserContent: NSObject, NSCoding {
    
    var contentCategory: String
    var contentDay: String
    var tasks: [String: UserTask]
    
    init(contentCategory: String, contentDay: String, tasks: [String: UserTask]) {
        self.contentCategory = contentCategory
        self.contentDay = contentDay
        self.tasks = tasks
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.contentCategory = aDecoder.decodeObject(forKey: "UserContentContentCategory") as? String ?? ""
        self.contentDay = aDecoder.decodeObject(forKey: "UserContentContentDay") as? String ?? ""
        self.tasks = aDecoder.decodeObject(forKey: "UserContentTasks") as? [String: UserTask] ?? ["":UserTask(taskCategory: "", taskTitle: "", taskType: "", taskDuration: "", items: [], videoUrl: "", answers: [], graphImage: "", max: "", mean: "", min: "", questions: [], resultIntro: "", resultSection: [], standardDeviation: "", taskDescription: "", infoTitle: "", infoImage: "", video: "", relatedVideos: [])]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(contentCategory, forKey: "UserContentContentCategory")
        aCoder.encode(contentDay, forKey: "UserContentContentDay")
        aCoder.encode(tasks, forKey: "UserContentTasks")
    }
}


class UserTask: NSObject, NSCoding {
    
    var taskCategory: String
    var taskTitle: String
    var taskType: String
    var taskDuration: String
    
    // checkoff
    var items: [String]
    
    // video
    var videoUrl: String
    
    // quiz
    var answers: [[String: String]]
    var graphImage: String
    var max: String
    var mean: String
    var min: String
    var questions: [String]
    var resultIntro: String
    var resultSection: [[String: String]]
    var standardDeviation: String
    
    // goal
    var taskDescription: String
    var infoTitle: String
    var infoImage: String
    var video: String
    var relatedVideos: [String]
    
    
    init(taskCategory: String, taskTitle: String, taskType: String, taskDuration: String, items: [String], videoUrl: String, answers: [[String: String]], graphImage: String, max: String, mean: String, min: String, questions: [String], resultIntro: String, resultSection: [[String: String]], standardDeviation: String, taskDescription: String, infoTitle: String, infoImage: String, video: String, relatedVideos: [String]) {
        
        self.taskCategory = taskCategory
        self.taskTitle = taskTitle
        self.taskType = taskType
        self.taskDuration = taskDuration
        
        self.items = items
        
        self.videoUrl = videoUrl
        
        self.answers = answers
        self.graphImage = graphImage
        self.max = max
        self.mean = mean
        self.min = min
        self.questions = questions
        self.resultIntro = resultIntro
        self.resultSection = resultSection
        self.standardDeviation = standardDeviation
        
        self.taskDescription = taskDescription
        self.infoTitle = infoTitle
        self.infoImage = infoImage
        self.video = video
        self.relatedVideos = relatedVideos
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let taskCategory = aDecoder.decodeObject(forKey: "UserTaskTaskCategory") as? String ?? ""
        let taskTitle = aDecoder.decodeObject(forKey: "UserTaskTaskTitle") as? String ?? ""
        let taskType = aDecoder.decodeObject(forKey: "UserTaskTaskType") as? String ?? ""
        let taskDuration = aDecoder.decodeObject(forKey: "UserTaskTaskDuration") as? String ?? ""
        let items = aDecoder.decodeObject(forKey: "UserTaskItems") as? [String] ?? []
        let videoUrl = aDecoder.decodeObject(forKey: "UserTaskVideoUrl") as? String ?? ""
        let answers = aDecoder.decodeObject(forKey: "UserTaskAnswers") as? [[String: String]] ?? []
        let graphImage = aDecoder.decodeObject(forKey: "UserTaskGraphImage") as? String ?? ""
        let max = aDecoder.decodeObject(forKey: "UserTaskMax") as? String ?? ""
        let mean = aDecoder.decodeObject(forKey: "UserTaskMean") as? String ?? ""
        let min = aDecoder.decodeObject(forKey: "UserTaskMin") as? String ?? ""
        let questions = aDecoder.decodeObject(forKey: "UserTaskQuestions") as? [String] ?? []
        let resultIntro = aDecoder.decodeObject(forKey: "UserTaskResultIntro") as? String ?? ""
        let resultSection = aDecoder.decodeObject(forKey: "UserTaskResultSecion") as? [[String: String]] ?? []
        let standardDeviation = aDecoder.decodeObject(forKey: "UserTaskStandardDeviation") as? String ?? ""
        let taskDescription = aDecoder.decodeObject(forKey: "UserTaskTaskDescription") as? String ?? ""
        let infoTitle = aDecoder.decodeObject(forKey: "UserTaskInfoTitle") as? String ?? ""
        let infoImage = aDecoder.decodeObject(forKey: "UserTaskInfoImage") as? String ?? ""
        let video = aDecoder.decodeObject(forKey: "UserTaskVideo") as? String ?? ""
        let relatedVideos = aDecoder.decodeObject(forKey: "UserTaskRelatedVideos") as? [String] ?? []
        
        self.init(taskCategory: taskCategory, taskTitle: taskTitle, taskType: taskType, taskDuration: taskDuration, items: items, videoUrl: videoUrl, answers: answers, graphImage: graphImage, max: max, mean: mean, min: min, questions: questions, resultIntro: resultIntro, resultSection: resultSection, standardDeviation: standardDeviation, taskDescription: taskDescription, infoTitle: infoTitle, infoImage: infoImage, video: video, relatedVideos: relatedVideos)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskCategory, forKey: "UserTaskTaskCategory")
        aCoder.encode(taskTitle, forKey: "UserTaskTaskTitle")
        aCoder.encode(taskType, forKey: "UserTaskTaskType")
        aCoder.encode(taskDuration, forKey: "UserTaskTaskDuration")
        aCoder.encode(items, forKey: "UserTaskItems")
        aCoder.encode(videoUrl, forKey: "UserTaskVideoUrl")
        aCoder.encode(answers, forKey: "UserTaskAnswers")
        aCoder.encode(graphImage, forKey: "UserTaskGraphImage")
        aCoder.encode(max, forKey: "UserTaskMax")
        aCoder.encode(mean, forKey: "UserTaskMean")
        aCoder.encode(min, forKey: "UserTaskMin")
        aCoder.encode(questions, forKey: "UserTaskQuestions")
        aCoder.encode(resultIntro, forKey: "UserTaskResultIntro")
        aCoder.encode(resultSection, forKey: "UserTaskResultSecion")
        aCoder.encode(standardDeviation, forKey: "UserTaskStandardDeviation")
        aCoder.encode(taskDescription, forKey: "UserTaskTaskDescription")
        aCoder.encode(infoTitle, forKey: "UserTaskInfoTitle")
        aCoder.encode(infoImage, forKey: "UserTaskInfoImage")
        aCoder.encode(video, forKey: "UserTaskVideo")
        aCoder.encode(relatedVideos, forKey: "UserTaskRelatedVideos")
    }
}

struct UserTaskStatusResult {
    var isCompleted: Bool
    var taskDay: Int
    
    var tasks: [String: UserTaskStatusResultItem]
    
    
}

struct UserTaskStatusResultItem {
    var attempts: [String: AttemptItem]
    var isComplete: Bool
    var type: String
}

struct AttemptItem {
    var date: Double
    var isComplete: Bool
    
    // video
    var rating: Int
    var adjective: String
    
    // quiz
    var answers: [Int]
    var result: Int
    
    // checkoff
    var items: [Bool]
    
    init(date: Double = 0, isComplete: Bool = false, rating: Int = 0, adjective: String = "", answers: [Int] = [Int](), result: Int = 0, items: [Bool] = [Bool]()) {
        self.date = date
        self.isComplete = isComplete
        self.rating = rating
        self.adjective = adjective
        
    }
}

struct DayTaskResult {
    
    var type: String
    var isComplete: Bool
    
    // video
    var adjective: String
    var rating: String
    
    // quiz
    var answers: [String]
    var result: String
    var dateComplete: String
    
    // checkoff
    var items: [Bool]
    
    init() {
        type = ""
        isComplete = false
        adjective = ""
        rating = ""
        answers = [String]()
        result = ""
        dateComplete = ""
        items = [Bool]()
    }
    
    init(type: String, isComplete: Bool, adjective: String, rating: String, answers: [String], result: String, dateComplete: String, items: [Bool]) {
        self.type = type
        self.isComplete = isComplete
        self.adjective = adjective
        self.rating = rating
        self.answers = answers
        self.result = result
        self.dateComplete = dateComplete
        self.items = items
    }
}

struct UserTaskResult {
    
    var isCheckedOff: Bool
    var isCompleted: Bool
    var taskDay: Int
    var tasks: [String: DayTaskResult]
    
    init(contentDayNo: Int) {
        isCheckedOff = false
        isCompleted = false
        taskDay = contentDayNo
        tasks = [String: DayTaskResult]()
    }
    
    init(isCheckedOff: Bool, isCompleted: Bool, taskDay: Int, tasks: [String: DayTaskResult]) {
        self.isCheckedOff = isCheckedOff
        self.isCompleted = isCompleted
        self.taskDay = taskDay
        self.tasks = tasks
    }
}

struct TestResults {
    var taskNo: String
    var dateComplete: String
    var score: String
    
    init(taskNo: String, dateComplete: String, score: String) {
        self.taskNo = taskNo
        self.dateComplete = dateComplete
        self.score = score
    }
}

class UserData {
    
    static let shared = UserData()

//    var userTools: UserTools?
    var userContents: [Int: UserContent]?
    
    
    var isTask1Finished = false
    var isTask2Finished = false
    var isTask3Finished = false
    
    
    var tasksTuplesArray: [(key: Int, value: UserContent)]?
    var availableTasksDict: [Int: UserContent]?
    
    var weekdays: [Int]?
    var tasksArr: [Int]?
    
    var currentContentDay = 0
    var currentTaskNo = -1
    
    var userTaskResult: UserTaskResult?
    var userDayTaskResultDict = [String: DayTaskResult]()
    
    // TODO: pull down user tasks data for certain days and store it in the singleton, if singleton is nil, pull down again
    var userTasksFinished: [String: UserTaskResult]?
    
    var userTestResults = [TestResults]()
    
    
    func getSelectedUserTask(dayNo: Int, taskNo: Int) -> UserTask? {
        
        if let arr = tasksTuplesArray {
            
            for taskTuple in arr {
                
                if taskTuple.key == dayNo {
                    
                    let userTasks = taskTuple.value.tasks
                    
                    for (k, v) in userTasks {
                        
                        if k.contains("task\(taskNo)") {
                            
                            return v
                            
                        }
                    }
                }
            }
            
        }
        return nil
    }
    
    
    func getCurrentSelectedUserTask(dayNo: Int, taskNo: Int) -> UserTask? {
        
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            
            let tasksArr = tasksDict.sorted(by: { (a, b) -> Bool in
                a.key < b.key
            })
            
            for task in tasksArr {
                
                print("task.key?????????? ✅ \(task.key)")
                
                if task.key == dayNo {
                    
                    let userTask = task.value.tasks
                        
                        
                        for (k, v) in userTask {
                            
                            if k.contains("task\(taskNo)") {
                                print("k.contains k value ✅ \(k)")
                                print("k.contains v value ✅ \(v.questions)")
                                return v
                            }
                            
                        }
                    }
                    
                    
                }
                
                
            }
            
           return nil
            
        }
    
    func getCheckoffItems(dayNo: Int, taskNo: Int) -> UserTask? {
        
        if let arr = tasksTuplesArray {
            
            for taskTuple in arr {
                
                if taskTuple.key == dayNo {
                    
                    let userTasks = taskTuple.value.tasks
                    
                    for (k, v) in userTasks {
                        
                        if k.contains("task\(taskNo)") {
                            
                            return v
                            
                        }
                    }
                }
            }
            
        }
        return nil
        
    }
    
    func getDailyUserContent(dayNo: Int) -> UserContent? {
        
        if let arr = tasksTuplesArray {
            
            for item in arr {
                
                if item.key == dayNo {
                    
                    return item.value
                    
                }
                
            }
        }
        return nil
    }
}
