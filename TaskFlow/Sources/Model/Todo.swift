//
//  Todo.swift
//  TaskFlow
//
//  Created by Данил Забинский on 05.02.2025.
//

import Foundation

struct Todo: Identifiable, Hashable {
    
    let id: UUID
    var title: String
    var section: MainTableSections = .sooner
    let createdAt: Date
    var finishedAt: Date?
    
    init(id: UUID, title: String, section: MainTableSections, createdAt: Date = .now, finishedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.section = section
        self.createdAt = createdAt
        self.finishedAt = finishedAt
    }
    
    mutating func changeSection() { section = (section == .sooner) ? .later : .sooner }
    mutating func finishTask() { finishedAt = .now }
    mutating func editTitle(updatedTitle title: String) { self.title = title }
    mutating func restoreTodo() { self.finishedAt = nil }
}

/*
// Функция для создания даты с использованием DateComponents
func createDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.timeZone = TimeZone.current // Используем текущую временную зону
    return Calendar.current.date(from: components)!
}

// Создаем массив задач вручную без использования DateFormatter
let todos: [Todo] = [
    // 1 октября - 2 задачи
    Todo(
        id: UUID(),
        title: "Купить продукты",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 1, hour: 9, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 1, hour: 10, minute: 30)
    ),
    Todo(
        id: UUID(),
        title: "Позвонить клиенту",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 1, hour: 14, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 1, hour: 15, minute: 15)
    ),
    
    // 3 октября - 3 задачи
    Todo(
        id: UUID(),
        title: "Закончить отчет",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 3, hour: 8, minute: 30),
        finishedAt: createDate(year: 2023, month: 10, day: 3, hour: 11, minute: 0)
    ),
    Todo(
        id: UUID(),
        title: "Провести собрание",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 3, hour: 13, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 3, hour: 14, minute: 30)
    ),
    Todo(
        id: UUID(),
        title: "Ответить на письма",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 3, hour: 16, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 3, hour: 17, minute: 0)
    ),
    
    // 5 октября - 1 задача
    Todo(
        id: UUID(),
        title: "Сходить в спортзал",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 5, hour: 18, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 5, hour: 19, minute: 30)
    ),
    
    // 7 октября - 2 задачи
    Todo(
        id: UUID(),
        title: "Прочитать книгу",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 7, hour: 10, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 7, hour: 12, minute: 0)
    ),
    Todo(
        id: UUID(),
        title: "Убраться дома",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 7, hour: 14, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 7, hour: 15, minute: 30)
    ),
    
    // 10 октября - 3 задачи
    Todo(
        id: UUID(),
        title: "Подготовить презентацию",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 10, hour: 9, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 10, hour: 11, minute: 0)
    ),
    Todo(
        id: UUID(),
        title: "Сходить к врачу",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 10, hour: 13, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 10, hour: 14, minute: 0)
    ),
    Todo(
        id: UUID(),
        title: "Купить подарок",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 10, hour: 16, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 10, hour: 17, minute: 30)
    ),
    
    // 15 октября - 1 задача
    Todo(
        id: UUID(),
        title: "Позвонить родителям",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 15, hour: 11, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 15, hour: 11, minute: 30)
    ),
    
    // 20 октября - 2 задачи
    Todo(
        id: UUID(),
        title: "Оплатить счета",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 20, hour: 9, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 20, hour: 9, minute: 30)
    ),
    Todo(
        id: UUID(),
        title: "Посмотреть фильм",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 20, hour: 19, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 20, hour: 21, minute: 0)
    ),
    
    // 25 октября - 3 задачи
    Todo(
        id: UUID(),
        title: "Сдать проект",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 25, hour: 8, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 25, hour: 10, minute: 0)
    ),
    Todo(
        id: UUID(),
        title: "Погулять в парке",
        section: .later,
        createdAt: createDate(year: 2023, month: 10, day: 25, hour: 14, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 25, hour: 15, minute: 30)
    ),
    Todo(
        id: UUID(),
        title: "Заказать доставку",
        section: .sooner,
        createdAt: createDate(year: 2023, month: 10, day: 25, hour: 18, minute: 0),
        finishedAt: createDate(year: 2023, month: 10, day: 25, hour: 18, minute: 30)
    )
]*/
